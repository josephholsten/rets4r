$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'test/unit'
require 'rets4r'

class CompactNokogiriTest < Test::Unit::TestCase
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
  def test_should_yield_between_results_if_given_a_block

  end
end
