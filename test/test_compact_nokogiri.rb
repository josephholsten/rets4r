#!/usr/bin/env ruby
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "."))
require 'test_helper'

class TestCompactNokogiri < Test::Unit::TestCase
  def test_should_do_stuff
    file = File.expand_path(File.join('test', 'data', '1.5', 'search_compact.xml'))
    listings = RETS4R::Client::CompactNokogiriParser.new(open(file)).to_a
    assert_equal({"Third"=>"Datum3", "Second"=>"Datum2", "First"=>"Datum1"}, listings[0])
    assert_equal({"Third"=>"Datum6", "Second"=>"Datum5", "First"=>"Datum4"}, listings[1])
  end
  def test_should_handle_big_data
    file = File.expand_path(File.join('test', 'data', '1.5', 'bad_compact.xml'))
    listings = RETS4R::Client::CompactNokogiriParser.new(open(file)).to_a
    assert_equal 1, listings.length
    assert_equal 79, listings.first.keys.length
  end
  def test_each_should_yield_between_results
    file = File.expand_path(
      File.join('test', 'data', '1.5', 'search_compact_big.xml'))
    stat = File::Stat.new(file)
    unless stat.size > stat.blksize
      flunk "This test probably won't work on this machine.
        It needs a test input file larger than the native block size."
    end
    stream = open(file)
    positions = []
    listings = RETS4R::Client::CompactNokogiriParser.new(stream).each do |row|
      positions << stream.pos
    end
    assert positions.first < positions.last,
      "data was yielded durring the reading of the stream"
  end
  def test_should_not_include_column_elements_in_keys
    response = "<RETS ReplyCode=\"0\" ReplyText=\"Operation Successful\">\r\n<DELIMITER value=\"09\" />\r\n<COLUMNS>\tDISPLAYORDER\tINPUTDATE\tMEDIADESCR\tMEDIANAME\tMEDIASOURCE\tMEDIATYPE\tMODIFIED\tPICCOUNT\tPRIMARYPIC\tTABLEUID\tUID\t</COLUMNS>\r\n<DATA>\t7\t2009-09-17 07:08:19 \t\tNew 023.jpg\t3155895-11.jpg\tpic\t2009-09-17 07:09:32 \t11\tn\t3155895\t9601458\t</DATA>\r\n<MAXROWS />\r\n</RETS>\r\n"

    assert RETS4R::Client::CompactNokogiriParser.new(StringIO.new(response)).map.first.keys.grep( /COLUMN/ ).empty?
  end
  context 'non-zero reply code' do
    setup do
      @response = <<-BODY
<?xml version="1.0"?>
<RETS ReplyCode="20203" ReplyText="User does not have access to Class named RES. Reference ID: 3fe82558-8015-4d9d-ab0c-776d9e4b5943" />
      BODY
      @parser = RETS4R::Client::CompactNokogiriParser.new(StringIO.new(@response))
    end
    should "raise the exception" do
      assert_raise RETS4R::Client::MiscellaneousSearchErrorException do
        @parser.to_a
      end
    end
    context 'when i parse' do
      should "contain the reply text in the exception message" do
        message = ''
        begin
          @parser.to_a
        rescue Exception => e
          message = e.message
        end
        assert_equal "User does not have access to Class named RES. Reference ID: 3fe82558-8015-4d9d-ab0c-776d9e4b5943", message
      end
    end
  end
end
