#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/auth'

class TestAuth < Test::Unit::TestCase
    def setup
      @useragent  = 'TestAgent/0.00'
      @username   = 'username'
      @password   = 'password'
      @realm      = 'REALM'
      @nonce      =  '2006-03-03T17:37:10'

      @auth = RETS4R::Auth.new.tap do |a|
        a.username = @username
        a.password = @password
        a.realm = @realm
        a.nonce = 'test'
        a.method = 'GET'
        a.uri = '/my/rets/url'
        a.request_id = 'test'
      end
    end

    def test_digest_authentication
        response = {
            'www-authenticate' => 'Digest qop="auth",realm="'+ @realm +'",nonce="'+ @nonce +'",opaque="",stale="false",domain="\my\test\domain"'
            }

        @auth.update_with_response response

        assert_match /^Digest/, @auth.to_s
    end

    def test_basic_authentication
        response = {
            'www-authenticate' => 'Basic realm="'+@realm+'"'
            }

        @auth.update_with_response response

        assert_match /^Basic/, @auth.to_s
    end

    # test without spacing
    def test_parse_auth_header_without_spacing
        header = 'Digest qop="auth",realm="'+ @realm +'",nonce="'+ @nonce +'",opaque="",stale="false",domain="\my\test\domain"'
        check_header(header)
    end

    # test with spacing between each item
    def test_parse_auth_header_with_spacing
        header = 'Digest qop="auth", realm="'+ @realm +'", nonce="'+ @nonce +'", opaque="", stale="false", domain="\my\test\domain"'
        check_header(header)
    end

    # used to check the that the header was processed properly.
    def check_header(header)
        results = RETS4R::Auth.parse_header(header)

        assert_equal('auth', results['qop'])
        assert_equal('REALM', results['realm'])
        assert_equal('2006-03-03T17:37:10', results['nonce'])
        assert_equal('', results['opaque'])
        assert_equal('false', results['stale'])
        assert_equal('\my\test\domain', results['domain'])
    end

    def test_calculate_digest
        @auth.qop = false
        assert_equal('bceafa34467a3519c2f6295d4800f4ea', @auth.response, 'without qop')

        @auth.qop = true
        assert_equal('08426a9012bdbb8dfe75d5e08d285418', @auth.response, 'with qop')
    end

    def test_request_id
        assert_not_nil(true, RETS4R::Auth.request_id)
    end

    def test_cnonce
        # We call cnonce with a static request ID so that we have a consistent result with which
        # to test against
        assert_equal('a13ebdc07593ad2de5a43224efb53394', @auth.cnonce)
    end
end
