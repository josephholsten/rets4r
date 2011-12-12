#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client/parsers/response_parser'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = RETS4R::Client::ResponseParser.new
  end

  # TODO: verify test_search_compact header, metadata
  def test_search_compact
    transaction = @parser.parse_results(fixture('search_compact.xml').read, 'COMPACT')

    assert_equal true, transaction.success?, "transaction should be successful"
    assert_equal 0, transaction.reply_code.to_i
    assert_equal 'SUCCESS', transaction.reply_text
    assert_equal [], transaction.header

    assert_equal nil, transaction.metadata

    assert_equal ?\t, transaction.delimiter
    assert_equal "\t", transaction.ascii_delimiter
    assert_equal true, transaction.max_rows?

    assert_equal 2, transaction.response.length, 'response length should be 2'
    assert_equal "Datum1", transaction.response[0]['First']
    assert_equal "Datum2", transaction.response[0]['Second']
    assert_equal "Datum3", transaction.response[0]['Third']
    assert_equal "Datum4", transaction.response[1]['First']
    assert_equal "Datum5", transaction.response[1]['Second']
    assert_equal "Datum6", transaction.response[1]['Third']

    assert_equal nil, transaction.secondary_response
  end

  # nokogiri should allow parsing these invalid documents without errors since
  # the boards of realtors are not at all reliable in sending correct xml
  def test_unescaped_search_compact
    assert_nothing_raised do
      @parser.parse_key_value(fixture('search_unescaped_compact.xml').read)
    end
  end

  def test_invalid_search_compact
    assert_nothing_raised do
      @parser.parse_key_value(fixture('search_unescaped_compact.xml').read)
    end
  end

  def test_login_results
    transaction = @parser.parse_key_value(fixture('login.xml').read)

    assert_equal true, transaction.success?
    assert_equal 'srealtor,1,11,11111', transaction.response['User']
    assert_equal '/rets/Login', transaction.response['Login']
  end

  def test_error_results
    exception = assert_raise(RETS4R::Client::InvalidResourceException) do
      @parser.parse_object_response(fixture('error.xml').read)
    end

    assert_equal '20400 - Invalid Invalidness.', exception.message
  end
end
