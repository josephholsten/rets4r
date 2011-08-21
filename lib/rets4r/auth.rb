require 'digest/md5'

module RETS4R
  class Auth
    attr_accessor :username, :password, :realm, :method, :uri, :qop,
      :cnonce, :nc, :nonce, :useragent, :request_id, :opaque, :current_strategy

    def initialize(nc = 1)
      self.nc = nc
      self.current_strategy = :none
    end

    def update(uri, method, requestId)
      self.uri = uri
      self.method = method
      self.request_id = requestId || Auth.request_id
      self.nc += 1
    end

    def update_with_response(response)
      if response['www-authenticate'].nil? || response['www-authenticate'].empty?
        self.current_strategy = :none
        warn "Missing required header 'www-authenticate'. Got: #{response}"
      elsif response['www-authenticate'] =~ /Basic/
        self.current_strategy = :basic
      else
        self.current_strategy = :digest
        # use Digest Authentication
        authHeader = Auth.parse_header(response['www-authenticate'])
        self.realm = authHeader['realm']
        self.nonce = authHeader['nonce']
        self.qop = authHeader['qop'] || false
        self.opaque = authHeader['opaque']
      end
    end

    def to_s
      case self.current_strategy
      when :none
        nil
      when :basic
        self.to_basic_header
      when :digest
        self.to_digest_header
      end
    end

    def self.authenticate(response, username, password, uri, method, requestId, useragent, nc = 0) # :nodoc:
      warn "#{caller.first}: warning: #{self.class}::authenticate is deprecated and will be removed by rets4r 2.0; use a RETS4R::Auth object instead"
      auth = RETS4R::Auth.new.tap do |a|
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

    def self.hA2(method, uri)
      Digest::MD5.hexdigest("#{method}:#{uri}")
    end

    def self.hA1(username, realm, password)
      Digest::MD5.hexdigest("#{username}:#{realm}:#{password}")
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

    def response
      if (qop)
        throw ArgumentException, 'qop requires a cnonce to be provided.' unless cnonce

        response = Digest::MD5.hexdigest("#{hA1}:#{nonce}:#{('%08x' % nc)}:#{cnonce}:#{qop}:#{hA2}")
      else
        response = Digest::MD5.hexdigest("#{hA1}:#{nonce}:#{hA2}")
      end
    end

    def hA1
      Digest::MD5.hexdigest("#{username}:#{realm}:#{password}")
    end

    def hA2
      Digest::MD5.hexdigest("#{method}:#{uri}")
    end

    def Auth.request_id
      Digest::MD5.hexdigest(Time.new.to_f.to_s)
    end

    def Auth.parse_header(header)
      type = header[0, header.index(' ')]
      args = header[header.index(' '), header.length].strip.split(',')

      parts = {'type' => type}

      args.each do |arg|
        name, value = arg.split('=')

        parts[name.downcase.strip] = value.tr('"', '').strip
      end

      return parts
    end
  end
end
