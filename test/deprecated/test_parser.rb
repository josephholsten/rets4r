#!/usr/bin/env ruby -w
testdir = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client/parsers/response_parser'

class TestParserDeprecatedBehavior < Test::Unit::TestCase
  def setup
    $VERBOSE = false
  end
  def teardown
    $VERBOSE = true
  end

  def test_search_compact
    transaction = RETS4R::Client::ResponseParser.new.parse_results(fixture('search_compact.xml').read, 'COMPACT')

    assert_equal transaction.max_rows?, transaction.maxrows?
    assert_equal transaction.response, transaction.data
    assert_equal transaction.reply_code.to_s, transaction.reply_code
  end
end
