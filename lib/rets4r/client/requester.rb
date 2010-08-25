require 'rets4r'
require 'rets4r/client/exceptions'

module RETS4R
  class Client
    class Requester
      DEFAULT_USER_AGENT      = "rets4r/#{::RETS4R::VERSION}"
      DEFAULT_RETS_VERSION    = '1.7'

      attr_accessor :logger, :headers, :pre_request_block, :nc, :username, :password, :method
      def initialize
        @nc = 0
        @headers = {
          'User-Agent'   => DEFAULT_USER_AGENT,
          'Accept'       => '*/*',
          'RETS-Version' => "RETS/#{DEFAULT_RETS_VERSION}",
        }
        @pre_request_block = nil
      end

      def user_agent
        @headers['User-Agent']
      end

      def user_agent=(name)
        set_header('User-Agent', name)
      end

      def rets_version=(version)
        if (SUPPORTED_RETS_VERSIONS.include? version)
          set_header('RETS-Version', "RETS/#{version}")
        else
          raise Unsupported.new("The client does not support RETS version '#{version}'.")
        end
      end

      def rets_version
        (@headers['RETS-Version'] || "").gsub("RETS/", "")
      end

      def set_header(name, value)
        if value.nil? then
          @headers.delete(name)
        else
          @headers[name] = value
        end

        logger.debug("Set header '#{name}' to '#{value}'") if logger
      end

      def user_agent
        @headers['User-Agent']
      end

      # Given a hash, it returns a URL encoded query string.
      def create_query_string(hash)
        parts = hash.map {|key,value| "#{CGI.escape(key)}=#{CGI.escape(value)}" unless key.nil? || value.nil?}
        return parts.join('&')
      end
      # This is the primary transaction method, which the other public methods make use of.
      # Given a url for the transaction (endpoint) it makes a request to the RETS server.
      #
      #--
      # This needs to be better documented, but for now please see the public transaction methods
      # for how to make use of this method.
      #++
      def request(url, data = {}, header = {}, method = @method, retry_auth = DEFAULT_RETRY)
        response = ''

        http = Net::HTTP.new(url.host, url.port)
        http.read_timeout = 600

        if logger && logger.debug?
          http.set_debug_output HTTPDebugLogger.new(logger)
        end

        http.start do |http|
          begin
            uri = url.path

            if ! data.empty? && method == METHOD_GET
              uri += "?#{create_query_string(data)}"
            end

            headers = @headers
            headers.merge(header) unless header.empty?

            @pre_request_block.call(self, http, headers) if @pre_request_block

            logger.debug(headers.inspect) if logger

            post_data = data.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') if method == METHOD_POST
            response  = method == METHOD_POST ? http.post(uri, post_data, headers) :
                                                http.get(uri, headers)


            if response.code == '401'
              # Authentication is required
              raise AuthRequired
            elsif response.code.to_i >= 300
              # We have a non-successful response that we cannot handle
              raise HTTPError.new(response)
            else
              cookies = []
              if set_cookies = response.get_fields('set-cookie') then
                set_cookies.each do |cookie|
                  cookies << cookie.split(";").first
                end
              end
              set_header('Cookie', cookies.join("; ")) unless cookies.empty?
              # totally wrong. session id is only ever under the Cookie header
              #set_header('RETS-Session-ID', response['RETS-Session-ID']) if response['RETS-Session-ID'] 
              set_header('RETS-Session-ID',nil)
            end
          rescue AuthRequired
            @nc += 1

            if retry_auth > 0
              retry_auth -= 1
                        auth = Auth.authenticate(response,
                                                                           @username,
                                                                           @password,
                                                                           url.path,
                                                                           method,
                                                                           @headers['RETS-Request-ID'],
                                                                           @headers['User-Agent'],
                                                                           @nc)
              set_header('Authorization', auth)
              retry
            else
              raise LoginError.new(response.message)
            end
          end

          logger.debug(response.body) if logger
        end

        return response
      end

    end
  end
end
