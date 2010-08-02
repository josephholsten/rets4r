# RETS4R Client
#
# Copyright (c) 2006 Scott Patterson <scott.patterson@digitalaun.com>
#
# This program is copyrighted free software by Scott Patterson.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003 (see the file RUBYS), or any later
# version.
#
#  TODO: 1.0 Support (Adding this support should be fairly easy)
#  TODO: 2.0 Support (Adding this support will be very difficult since it is a completely different methodology)
#  TODO: Case-insensitive header

require 'digest/md5'
require 'net/http'
require 'uri'
require 'cgi'
require 'auth'
require 'client/dataobject'
require 'client/parsers/response_parser'
require 'client/parsers/compact'
require 'rets4r/client/links'
require 'rets4r/client/requester'
require 'rets4r/client/exceptions'
require 'rets4r/client/metadata_request'
require 'logger'
require 'webrick/httputils'

module RETS4R
  class Client
    COMPACT_FORMAT = 'COMPACT'

    METHOD_GET  = 'GET'
    METHOD_POST = 'POST'
    METHOD_HEAD = 'HEAD'

    DEFAULT_METHOD          = METHOD_GET
    DEFAULT_RETRY           = 2
    SUPPORTED_RETS_VERSIONS = ['1.5', '1.7']
    CAPABILITY_LIST   = [
            'Action',
            'ChangePassword',
            'GetObject',
            'Login',
            'LoginComplete',
            'Logout',
            'Search',
            'GetMetadata',
            'Update'
        ]

    # These are the response messages as defined in the RETS 1.5e2 and 1.7d6 specifications.
    # Provided for convenience and are used by the HTTPError class to provide more useful
    # messages.
    RETS_HTTP_MESSAGES = {
      '200' => 'Operation successful.',
      '400' => 'The request could not be understood by the server due to malformed syntax.',
      '401' => 'Either the header did not contain an acceptable Authorization or the ' +
                             'username/password was invalid. The server response MUST include a ' +
                             'WWW-Authenticate header field.',
      '402' => 'The requested transaction requires a payment which could not be authorized.',
      '403' => 'The server understood the request, but is refusing to fulfill it.',
      '404' => 'The server has not found anything matching the Request-URI.',
      '405' => 'The method specified in the Request-Line is not allowed for the resource ' +
                             'identified by the Request-URI.',
      '406' => 'The resource identified by the request is only capable of generating response ' +
                             'entities which have content characteristics not acceptable according to the accept ' +
                             'headers sent in the request.',
      '408' => 'The client did not produce a request within the time that the server was prepared to wait.',
      '411' => 'The server refuses to accept the request without a defined Content-Length.',
      '412' => 'Transaction not permitted at this point in the session.',
      '413' => 'The server is refusing to process a request because the request entity is larger than ' +
                             'the server is willing or able to process.',
      '414' => 'The server is refusing to service the request because the Request-URI is longer than ' +
                             'the server is willing to interpret. This error usually only occurs for a GET method.',
      '500' => 'The server encountered an unexpected condition which prevented it from fulfilling ' +
                             'the request.',
      '501' => 'The server does not support the functionality required to fulfill the request.',
      '503' => 'The server is currently unable to handle the request due to a temporary overloading ' +
                             'or maintenance of the server.',
      '505' => 'The server does not support, or refuses to support, the HTTP protocol version that ' +
                             'was used in the request message.',
    }

    attr_accessor :mimemap
    attr_reader :format, :urls

    # Constructor
    #
    # Requires the URL to the RETS server and takes an optional output format. The output format
    # determines the type of data returned by the various RETS transaction methods.
    def initialize(url, format = COMPACT_FORMAT)
      @request_struct = RETS4R::Client::Requester.new
      @format   = format
      @urls     = RETS4R::Client::Links.from_login_url(url)

      @request_method = DEFAULT_METHOD

      @response_parser = RETS4R::Client::ResponseParser.new

      self.mimemap    = {
        'image/jpeg'  => 'jpg',
        'image/gif'   => 'gif'
      }

      if block_given?
        yield self
      end
    end

    # Assigns a block that will be called just before the request is sent.
    # This block must accept three parameters:
    # * self
    # * Net::HTTP instance
    # * Hash of headers
    #
    # The block's return value will be ignored.  If you want to prevent the request
    # to go through, raise an exception.
    #
    # == Example
    #
    #  client = RETS4R::Client.new(...)
    #  # Make a new pre_request_block that calculates the RETS-UA-Authorization header.
    #  client.set_pre_request_block do |rets, http, headers|
    #    a1 = Digest::MD5.hexdigest([headers["User-Agent"], @password].join(":"))
    #    if headers.has_key?("Cookie") then
    #      cookie = headers["Cookie"].split(";").map(&:strip).select {|c| c =~ /rets-session-id/i}
    #      cookie = cookie ? cookie.split("=").last : ""
    #    else
    #      cookie = ""
    #    end
    #
    #    parts = [a1, "", cookie, headers["RETS-Version"]]
    #    headers["RETS-UA-Authorization"] = "Digest " + Digest::MD5.hexdigest(parts.join(":"))
    #  end
    def set_pre_request_block(&block)
      @request_struct.pre_request_block = block
    end

    # So very much delegated to the request struct
    def set_header(name, value)
      @request_struct.set_header(name, value)
    end

    def get_header(name)
      @request_struct.headers[name]
    end

    def user_agent=(name)
      @request_struct.set_header('User-Agent', name)
    end

    def user_agent
      @request_struct.user_agent
    end

    def rets_version=(version)
      @request_struct.rets_version = version
    end

    def rets_version
      @request_struct.rets_version
    end

    def request_method=(method)
      @request_method = method
      @request_struct.method = method
    end

    def request_method
      @request_method
    end

    def logger=(logger)
      @logger = logger
      @request_struct.logger = logger
    end

    def logger
      @logger
    end

    #### RETS Transaction Methods ####
    #
    # Most of these transaction methods mirror the RETS specification methods, so if you are
    # unsure what they mean, you should check the RETS specification. The latest version can be
    # found at http://www.rets.org

    # Attempts to log into the server using the provided username and password.
    #
    # If called with a block, the results of the login action are yielded,
    # and logout is called when the block returns.  In that case, #login
    # returns the block's value. If called without a block, returns the
    # result.
    #
    # As specified in the RETS specification, the Action URL is called and
    # the results made available in the #secondary_results accessor of the
    # results object.
    def login(username, password) #:yields: login_results
      @request_struct.username = username
      @request_struct.password = password

      # We are required to set the Accept header to this by the RETS 1.5 specification.
      set_header('Accept', '*/*')

      response = request(@urls.login)

      # Parse response to get other URLS
      results = @response_parser.parse_key_value(response.body)

      if (results.success?)
        CAPABILITY_LIST.each do |capability|
          next unless results.response[capability]

          uri = URI.parse(results.response[capability])

          if uri.absolute?
            @urls[capability] = uri
          else
            base = @urls.login.clone
            base.path = results.response[capability]
            @urls[capability] = base
          end
        end

        logger.debug("Capability URL List: #{@urls.inspect}") if logger
      else
        raise LoginError.new(response.message + "(#{results.reply_code}: #{results.reply_text})")
      end

      # Perform the mandatory get request on the action URL.
      results.secondary_response = perform_action_url

      # We only yield
      if block_given?
        begin
          yield results
        ensure
          self.logout
        end
      else
        results
      end
    end

    # Logs out of the RETS server.
    def logout()
      # If no logout URL is provided, then we assume that logout is not necessary (not to
      # mention impossible without a URL). We don't throw an exception, though, but we might
      # want to if this becomes an issue in the future.

      request(@urls.logout) if @urls.logout
    end

    # Requests Metadata from the server. An optional type and id can be specified to request
    # subsets of the Metadata. Please see the RETS specification for more details on this.
    # The format variable tells the server which format to return the Metadata in. Unless you
    # need the raw metadata in a specified format, you really shouldn't specify the format.
    #
    # If called with a block, yields the results and returns the value of the block, or
    # returns the metadata directly.
    def get_metadata(type = 'METADATA-SYSTEM', id = '*')
      xml = download_metadata(type, id)

      result = @response_parser.parse_metadata(xml, @format)

      if block_given?
        yield result
      else
        result
      end
    end

    def download_metadata(type, id)
      req = MetadataRequest.new(@urls.metadata, type, id, @format, @request_struct)
      req.request.body
    end

    # Performs a GetObject transaction on the server. For details on the arguments, please see
    # the RETS specification on GetObject requests.
    #
    # This method either returns an Array of DataObject instances, or yields each DataObject
    # as it is created. If a block is given, the number of objects yielded is returned.
    #
    # TODO: how much of this could we move over to WEBrick::HTTPRequest#parse?
    def get_object(resource, type, id, location = false) #:yields: data_object
      header = {
        'Accept' => mimemap.keys.join(',')
      }

      data = {
        'Resource' => resource,
        'Type'     => type,
        'ID'       => id,
        'Location' => location ? '1' : '0'
      }

      response = request(@urls.objects, data, header)
      results = block_given? ? 0 : []

      if response['content-type'] && response['content-type'].include?('text/xml')
        # This probably means that there was an error.
        # Response parser will likely raise an exception.
        rr = @response_parser.parse_object_response(response.body)
        return rr
      elsif response['content-type'] && response['content-type'].include?('multipart/parallel')
        content_type = process_content_type(response['content-type'])

#        TODO: log this
#        puts "SPLIT ON #{content_type['boundary']}"
        boundary = content_type['boundary']
        if boundary =~ /\s*'([^']*)\s*/
          boundary = $1
        end
        parts = response.body.split("\r\n--#{boundary}")

        parts.shift # Get rid of the initial boundary

#        TODO: log this
#        puts "GOT PARTS #{parts.length}"

        parts.each do |part|
          (raw_header, raw_data) = part.split("\r\n\r\n")

#          TODO: log this
#          puts raw_data.nil?
          next unless raw_data

          data_header = process_header(raw_header)
          data_object = DataObject.new(data_header, raw_data)

          if block_given?
            yield data_object
            results += 1
          else
            results << data_object
          end
        end
      else
        info = {
          'content-type' => response['content-type'], # Compatibility shim.  Deprecated.
          'Content-Type' => response['content-type'],
          'Object-ID'    => response['Object-ID'],
          'Content-ID'   => response['Content-ID']
        }

        if response['Transfer-Encoding'].to_s.downcase == "chunked" || response['Content-Length'].to_i > 100 then
          data_object = DataObject.new(info, response.body)
          if block_given?
            yield data_object
            results += 1
          else
            results << data_object
          end
        end
      end

      results
    end

    # Peforms a RETS search transaction. Again, please see the RETS specification for details
    # on what these parameters mean. The options parameter takes a hash of options that will
    # added to the search statement.
    def search(search_type, klass, query, options = false)
      header = {}

      # Required Data
      data = {
        'SearchType' => search_type,
        'Class'      => klass,
        'Query'      => query,
        'QueryType'  => 'DMQL2',
        'Format'     => format,
        'Count'      => '0'
      }

      # Options
      #--
      # We might want to switch this to merge!, but I've kept it like this for now because it
      # explicitly casts each value as a string prior to performing the search, so we find out now
      # if can't force a value into the string context. I suppose it doesn't really matter when
      # that happens, though...
      #++
      options.each { |k,v| data[k] = v.to_s } if options

      response = request(@urls.search, data, header)

      # TODO: make parser configurable
      results = RETS4R::Client::CompactNokogiriParser.new(response.body)

      if block_given?
        results.each {|result| yield result}
      else
        return results.to_a
      end
    end

    def count(search_type, klass, query)
      header = {}
      data = {
        'SearchType' => search_type,
        'Class'      => klass,
        'Query'      => query,
        'QueryType'  => 'DMQL2',
        'Format'     => format,
        'Count'      => '2'
      }
      response = request(@urls.search, data, header)
      result = @response_parser.parse_count(response.body)
      return result
    end

    private

    # XXX: This is crap. It does not properly handle quotes.
    def process_content_type(text)
      content = {}

      field_start = text.index(';')

      content['content-type'] = text[0 ... field_start].strip
      fields = text[field_start..-1]

      parts = text.split(';')

      parts.each do |part|
        (name, value) = part.gsub(/\"/, '').split('=')

        content[name.strip] = value ? value.strip : value
      end

      content
    end

    # Processes the HTTP header
    #--
    #++
    def process_header(raw)
      # this util gives us arrays of values. We are only set up to handle one header value.
      WEBrick::HTTPUtils.parse_header(raw.strip).map.inject({}) do |h,(k,v)|
        h[k]=v.first; h
      end
    end

    # This is the primary transaction method, which the other public methods make use of.
    # Given a url for the transaction (endpoint) it makes a request to the RETS server.
    #
    #--
    # This needs to be better documented, but for now please see the public transaction methods
    # for how to make use of this method.
    #++
    def request(url, data = {}, header = {}, method = @request_method, retry_auth = DEFAULT_RETRY)
      @request_struct.request(url, data, header, method, retry_auth)
    end

    # If an action URL is present in the URL capability list, it calls that action URL and returns the
    # raw result. Throws a generic RETSException if it is unable to follow the URL.
    def perform_action_url
      begin
        if @urls.has_key?('Action')
          return request(@urls.action, {}, {}, METHOD_GET)
        end
      rescue
        raise RETSException.new("Unable to follow action URL: '#{$!}'.")
      end
    end

    # Provides a proxy class to allow for net/http to log its debug to the logger.
    class HTTPDebugLogger
      def initialize(logger)
        @logger = logger
      end

      def <<(data)
        @logger.debug(data)
      end
    end
  end
end
