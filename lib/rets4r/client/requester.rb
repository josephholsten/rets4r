require 'rets4r'
require 'rets4r/client/exceptions'

module RETS4R
  class Client
    class Requester
      DEFAULT_USER_AGENT      = "rets4r/#{::RETS4R::VERSION}"
      DEFAULT_RETS_VERSION    = '1.7'

      attr_accessor :logger, :headers, :pre_request_block, :post_request_block, :auth
      attr_reader :username, :password, :method

      def initialize
        @headers = {
          'User-Agent'   => DEFAULT_USER_AGENT,
          'Accept'       => '*/*',
          'RETS-Version' => "RETS/#{DEFAULT_RETS_VERSION}",
        }
        @pre_request_block = nil
        @post_request_block = nil
        @method = METHOD_GET
        @auth = RETS4R::Auth.new
      end

      def user_agent
        @headers['User-Agent']
      end

      def user_agent=(name)
        auth.user_agent = name
        set_header('User-Agent', name)
      end

      def username=(name)
        @username = name
        auth.username = name
      end

      def password=(pass)
        @password = pass
        auth.password = pass
      end

      def method=(method)
        @method = method
        auth.method = method
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

        begin
          http.start do |sess|
            begin
              uri = url.path

              if ! data.empty? && method == METHOD_GET
                uri += "?#{create_query_string(data)}"
              end

              headers = @headers
              headers.merge(header) unless header.empty?

              @pre_request_block.call(self, sess, headers) if @pre_request_block

              logger.debug("Sending headers #{headers.inspect}") if logger

              post_data = data.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') if method == METHOD_POST
              auth.update(url.path, method, @headers['RETS-Request-ID'])
              set_header('Authorization', auth.to_s)

              response  = method == METHOD_POST ? sess.post(uri, post_data, headers) :
                                                  sess.get(uri, headers)


              if response.code == '401'
                # Authentication is required
                raise AuthRequired
              elsif response.code.to_i >= 300
                # We have a non-successful response that we cannot handle
                raise HTTPError.new(response)
              else
                cookies = collect_cookies response
                logger.debug("Recieved cookies '#{cookies.inspect}'") if logger
                set_cookies cookies
              end
            rescue AuthRequired
              if retry_auth > 0
                retry_auth -= 1
                auth.update_with_response(response)
                retry
              else
                raise LoginError.new(response.message)
              end
            end

            logger.debug("Recieved headers #{response.to_hash.inspect}") if logger
            logger.debug("Recieved response #{response.body}") if logger
          end
        rescue
          raise ClientException.new("Error connecting to #{url.host}:#{url.port}\n#{$!}")
        end

        @post_request_block.call(self, http, headers) if @post_request_block

        return response
      end

      def collect_cookies(response)
        cookies = {}
        cookie_fields = response.get_fields('set-cookie') || []
        cookie_fields.each do |cookie|
          # Cookies are of the form
          #   JSESSIONID=7939CD3932648EA8F3C0D27723154039; Path=/
          # So we need to strip the path component
          key, value = cookie.split(";").first.split('=')
          cookies.store key, value
        end
        cookies
      end

      def set_cookies(cookies)
        cookie_string = cookies.map{|k,v| "#{k}=#{v}"}.join('; ')
        set_header('Cookie', cookie_string) unless cookies.empty?
      end

    end
  end
end
