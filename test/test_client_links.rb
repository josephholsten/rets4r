#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client/links'

class TestClientLinks < Minitest::Test
  def setup
    @links = RETS4R::Client::Links.from_login_url('http://example.com/login')
    @links['Logout'] = URI.parse('http://example.com/logout')
    @links['GetMetadata'] = URI.parse('http://example.com/metadata')
    @links['GetObject'] = URI.parse('http://example.com/objects')
    @links['Search'] = URI.parse('http://example.com/search')
    @links['Action'] = URI.parse('http://example.com/action')
  end
  def test_should_build_from_login_url
    assert_equal normalize_url('http://example.com/login'), @links['Login'].to_s
  end
  def test_should_access_login
    assert_equal normalize_url('http://example.com/login'), @links.login.to_s
  end
  def test_should_access_logout
    assert_equal normalize_url('http://example.com/logout'), @links.logout.to_s
  end
  def test_should_access_metadata
    assert_equal normalize_url('http://example.com/metadata'), @links.metadata.to_s
  end
  def test_should_access_object
    assert_equal normalize_url('http://example.com/objects'), @links.objects.to_s
  end
  def test_should_access_search
    assert_equal normalize_url('http://example.com/search'), @links.search.to_s
  end
  def test_should_access_action
    assert_equal normalize_url('http://example.com/action'), @links.action.to_s
  end
  def normalize_url(url)
    URI.parse(url).to_s
  end
end
