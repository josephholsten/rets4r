$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rets4r'
require 'test/unit'

class LoaderTest < Test::Unit::TestCase
  def test_should_pass_records_to_block
    file = File.expand_path(File.join('test', 'data', '1.5', 'search_compact.xml'))

    listings = []
    RETS4R::Loader.load(open(file)) do |record|
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