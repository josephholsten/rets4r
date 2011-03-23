require 'uri'

module RETS4R #:nodoc:
  class Client #:nodoc:
    class Links < Hash
      attr_accessor :logger
      def self.from_login_url(login_url)
        links = self.new
        links['Login'] = URI.parse(login_url)
        links
      end
      #--
      # TODO: test this and remove crap from Client#login
      # def []=(capability, uri)
      #   uri = URI.parse(uri) unless URI === uri
      #   if uri.absolute?
      #     super(capability, uri)
      #   else
      #     base = self.login.clone
      #     base.path = results.response[capability]
      #     super(capability, base)
      #   end
      # end
      #++
      def login
        self['Login']
      end
      def logout
        self['Logout']
      end
      def metadata
        self['GetMetadata']
      end
      def objects
        self['GetObject']
      end
      def search
        self['Search']
      end
      def action
        self['Action']
      end
    end
  end
end
