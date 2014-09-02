#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/auth'

class TestAuth < Minitest::Test
  def setup
    @auth = RETS4R::Auth.new.tap do |a|
      a.username = 'username'
      a.password = 'password'
      a.method = 'GET'
      a.uri = '/my/rets/url'
      a.request_id = 'test'
      a.useragent = 'TestAgent/0.00'
    end
  end

  def test_digest_authentication_with_qop
    response = {
      'www-authenticate' => 'Digest '+
        'qop="auth",'+
        'realm="REALM",'+
        'nonce="' + '2006-03-03T17:37:10' + '",'+
        'opaque="5ccc069c403ebaf9f0171e9517f40e41",'+
        'stale="false",'+
        'domain="\my\test\domain"' }

    @auth.update_with_response response

    expected = 'Digest '+
      'username="username", '+
      'realm="REALM", '+
      'qop="auth", '+
      'uri="/my/rets/url", '+
      'nonce="2006-03-03T17:37:10", '+
      'nc=00000001, '+
      'cnonce="32cc9e7f3a4f6ad3127bb00715dd0fda", '+
      'response="2bbd0d5b73bb5714906c3011b57e644c", '+
      'opaque="5ccc069c403ebaf9f0171e9517f40e41"'
    assert_equal expected, @auth.to_s
  end

  def test_digest_authentication_without_qop
    digest_header = 'Digest realm="REALM",nonce="2006-03-03T17:37:10",opaque="5ccc069c403ebaf9f0171e9517f40e41",stale="false",domain="\my\test\domain"'

    @auth.update_with_response 'www-authenticate' => digest_header

    expected = 'Digest '+
      'username="username", '+
      'realm="REALM", '+
      'uri="/my/rets/url", '+
      'nonce="2006-03-03T17:37:10", '+
      'response="58962110796b5ce18fd89c91e10e9aeb", '+
      'opaque="5ccc069c403ebaf9f0171e9517f40e41"'
    assert_equal expected, @auth.to_s
  end

  def test_digest_authentication_for_www_authenticate_with_spaces
    digest_header_without_spaces = 'Digest realm="REALM",nonce="2006-03-03T17:37:10",opaque="5ccc069c403ebaf9f0171e9517f40e41",stale="false",domain="\my\test\domain"'
    digest_header_with_spaces    = 'Digest realm="REALM", nonce="2006-03-03T17:37:10", opaque="5ccc069c403ebaf9f0171e9517f40e41", stale="false", domain="\my\test\domain"'
    expected_auth = @auth.dup
    expected_auth.update_with_response('www-authenticate' => digest_header_without_spaces)

    @auth.update_with_response 'www-authenticate' => digest_header_with_spaces

    assert_equal expected_auth.to_s, @auth.to_s
  end

  def test_basic_authentication
    auth = RETS4R::Auth.new.tap do |a|
       a.username = 'Aladdin'
       a.password = 'open sesame'
     end
    response = { 'www-authenticate' => 'Basic realm="WallyWorld"' }

    auth.update_with_response response

    assert_equal 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==', auth.to_s
  end
end
