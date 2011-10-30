require 'digest/md5'

module RETS4R
  class Auth
    attr_accessor :current_strategy, :method, :nc, :nonce, :opaque, :password,
      :qop, :realm, :request_id, :uri, :useragent, :username

    def initialize(nc = 1)
      self.nc = nc
      self.current_strategy = :none
    end

    def update(uri, method, requestId)
      self.uri = uri
      self.method = method
      self.request_id = requestId || self.class.request_id
      self.nc += 1
    end

    def update_with_response(response)
      if response['www-authenticate'].nil? || response['www-authenticate'].empty?
        self.current_strategy = :none
        warn "Missing required header 'www-authenticate'. Got: #{response}"
      else
        header = Auth::ResponseHeader.parse(response['www-authenticate'])
        self.current_strategy = header.strategy
        self.realm = header.realm
        self.nonce = header.nonce
        self.qop = header.qop
        self.opaque = header.opaque
      end
      self
    end

    def to_s
      case current_strategy
      when :none
        nil
      when :basic
        to_basic_header
      when :digest
        to_digest_header
      end
    end

    def self.authenticate(response, username, password, uri, method, requestId, useragent, nc = 0) # :nodoc:
      warn "#{caller.first}: warning: #{self.class}::authenticate is deprecated and will be removed by rets4r 2.0; use a RETS4R::Auth object instead"
      auth = new.tap do |a|
        a.username = username
        a.password = password
        a.uri = uri
        a.method = method
        a.request_id = requestId
        a.useragent = useragent
        a.nc = nc
      end

      auth.update_with_response response

      auth.to_s
    end

    def self.calculate_digest(username, password, realm, nonce, method, uri, qop = false, cnonce = false, nc = 0) # :nodoc:
      warn "#{caller.first}: warning: #{self.class}::authenticate is deprecated and will be removed by rets4r 2.0; use a RETS4R::Auth object instead"
      text = [hA1(username, realm, password), nonce]
      if (qop)
        throw ArgumentException, 'qop requires a cnonce to be provided.' unless cnonce

        text << '%08x' % nc << cnonce << qop
      end
      text << hA2(method, uri)

      return Digest::MD5.hexdigest text.join(':')
    end

    def self.cnonce(useragent, password, requestId, nonce) # :nodoc:
      warn "#{caller.first}: warning: #{self.class}::cnonce is deprecated and will be removed by rets4r 2.0; use a RETS4R::Auth object instead"
      Digest::MD5.hexdigest("#{useragent}:#{password}:#{requestId}:#{nonce}")
    end

    def self.parse_header(header) # :nodoc:
      warn "#{caller.first}: warning: #{self.class}::parse_header is deprecated and will be removed by rets4r 2.0; use RETS4R::Auth::ResponseHeader.parse instead"
      RETS4R::Auth::ResponseHeader.parse(header).to_h
    end

    def self.hA2(method, uri) # :nodoc:
      Digest::MD5.hexdigest("#{method}:#{uri}")
    end

    def self.hA1(username, realm, password) # :nodoc:
      Digest::MD5.hexdigest("#{username}:#{realm}:#{password}")
    end

    def self.request_id # :nodoc:
      Digest::MD5.hexdigest(Time.new.to_f.to_s)
    end

    private

    def response
      text = [hA1, nonce]
      if (qop)
        throw ArgumentException, 'qop requires a cnonce to be provided.' unless cnonce

        text << '%08x' % nc << cnonce << qop
      end
      text << hA2

      return Digest::MD5.hexdigest text.join(':')
    end

    def to_basic_header
      'Basic ' + ["#{username}:#{password}"].pack('m').delete("\r\n")
    end

    def to_digest_header
      header = ''
      header << "Digest username=\"#{username}\", "
      header << "realm=\"#{realm}\", "
      header << "qop=\"#{qop}\", " if qop
      header << "uri=\"#{uri}\", "
      header << "nonce=\"#{nonce}\", "
      header << "nc=#{('%08x' % nc)}, " if qop
      header << "cnonce=\"#{cnonce}\", " if qop
      header << "response=\"#{response}\", "
      header << "opaque=\"#{opaque}\""
      header
    end

    def cnonce
      Digest::MD5.hexdigest("#{useragent}:#{password}:#{request_id}:#{nonce}")
    end

    def hA1
      Digest::MD5.hexdigest("#{username}:#{realm}:#{password}")
    end

    def hA2
      Digest::MD5.hexdigest("#{method}:#{uri}")
    end

    class ResponseHeader
      ACCEPTABLE_KEYS = %w[realm domain nonce opaque stale algorithm qop]
      attr_accessor :strategy, *ACCEPTABLE_KEYS

      def self.parse(header)
        new.tap do |auth|
          auth.strategy = header[0, header.index(' ')].downcase.to_sym
          args = header[header.index(' '), header.length].strip.split(',')

          args.each do |arg|
            key, value = arg.split('=')
            key = key.downcase.strip
            value = value.tr('"', '').strip
            if ACCEPTABLE_KEYS.include? key
              auth.send("#{key}=".to_sym, value)
            else
              warn "#{caller.first}: warning: response header contained unknown value #{key}: \"#{value}\", skipping"
            end
          end
        end
      end

      # convert the header to a hash. Uses strings for keys, with 'type containing the
      # Examples:
      #   header = 'Digest qop="auth", realm="REALM", nonce="2006-03-03T17:37:10", opaque="", stale="false", domain="test-domain"'
      #   ResponseHeader.parse(header).to_h
      #   => { "type" => "digest", "qop" => "auth", "realm" => "REALM", "nonce" => "2006-03-03T17:37:10", "opaque" => "", "stale" => "false", "domain" => "test-domain"}
      def to_h
        result = {}
        result['type'] = self.strategy
        ACCEPTABLE_KEYS.each do |key|
          result[key] = self.send(key)
        end
        result
      end
    end
  end
end
