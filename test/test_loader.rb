#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/loader'

class TestLoader < Test::Unit::TestCase
  def test_should_pass_records_to_block
    listings = []
    RETS4R::Loader.load(fixture('search_compact.xml').open) do |record|
      listings << record
    end

    assert_equal 2, listings.length
    assert_equal "Datum1", listings[0]['First']
    assert_equal "Datum2", listings[0]['Second']
    assert_equal "Datum3", listings[0]['Third']
    assert_equal "Datum4", listings[1]['First']
    assert_equal "Datum5", listings[1]['Second']
    assert_equal "Datum6", listings[1]['Third']

  end
end