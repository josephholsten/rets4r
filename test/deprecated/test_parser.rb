#!/usr/bin/env ruby -w
testdir = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client/parsers/response_parser'

class TestParserDeprecatedBehavior < Test::Unit::TestCase
  def setup
    @parser = RETS4R::Client::ResponseParser.new
  end

  def parse_to_transaction(xml_path_name)
    @parser.parse_key_value(xml_path_name.read)
  end

  def test_search_compact
    transaction = @parser.parse_results(fixture('search_compact.xml').read, 'COMPACT')

    assert_equal transaction.max_rows?, transaction.maxrows?
    assert_equal transaction.response, transaction.data
    assert_equal transaction.reply_code.to_s, transaction.reply_code
  end
end
