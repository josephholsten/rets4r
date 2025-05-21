#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client'

require 'webrick/httpstatus'

class TestClientGetObject < Minitest::Test
    RETS_PORT     = '9080'
    RETS_URL      = "http://localhost:#{RETS_PORT}"
    RETS_LOGIN    = 'login'
    RETS_PASSWORD = 'password'

    class CustomError < StandardError; end

    def setup
        @logfile = StringIO.open
        @rets    = RETS4R::Client.new(RETS_URL)
        @rets.logger = Logger.new(@logfile)
        @rets.logger.level = Logger::DEBUG

        @rets.stubs(:request).returns(@response = mock("response"))
    end

    def test_returns_multipart_parallel_objects_in_a_single_array(boundary = "1231")
        @response.expects(:[]).with('content-type').at_least_once.returns("multipart/parallel; boundary=#{boundary}")
        @response.expects(:body).returns("\r\n--1231\r\nContent-ID: 392103\r\nObject-ID: 1\r\nContent-Type: image/jpeg\r\n\r\n" + "\000"*120 + "\r\n--1231\r\nContent-ID: 392103\r\nObject-ID: 2\r\nContent-Type: image/gif\r\n\r\n" + "\000"*140 + "\r\n--1231--")
        results = @rets.get_object("Property", "Photo", "392103:*")
        assert_equal 2, results.size, "Client should parse two objects out of the request"
        assert_kind_of RETS4R::Client::DataObject, results[0], "First result isn't a DataObject"
        assert_kind_of RETS4R::Client::DataObject, results[1], "Second result isn't a DataObject"
        assert_equal "image/jpeg", results[0].type["Content-Type"], "First object isn't an image/jpeg"
        assert_equal 120, results[0].data.size, "First object isn't 120 bytes in length"
        assert_equal "image/gif", results[1].type["Content-Type"], "Second object isn't an image/gif"
        assert_equal 140, results[1].data.size, "Second object isn't 140 bytes in length"
    end

    def test_returns_multipart_parallel_objects_in_a_single_array_boundary_with_double_quotes
        test_returns_multipart_parallel_objects_in_a_single_array('"1231"')
    end

    def test_returns_multipart_parallel_objects_in_a_single_array_boundary_with_single_quotes
        test_returns_multipart_parallel_objects_in_a_single_array("'1231'")
    end

    def test_returns_single_entity_object_in_a_single_element_array
        @response.expects(:[]).with('content-type').at_least_once.returns("image/jpeg")
        @response.expects(:[]).with('Transfer-Encoding').at_least_once.returns("")
        @response.expects(:[]).with('Content-Length').at_least_once.returns(241)
        @response.expects(:[]).with('Object-ID').at_least_once.returns("25478")
        @response.expects(:[]).with('Content-ID').at_least_once.returns("5589")
        @response.expects(:body).returns("\000"*241)

        results = @rets.get_object("Property", "Photo", "392103:*")
        assert_equal 1, results.size, "Client parsed one object out of the request"
        assert_kind_of RETS4R::Client::DataObject, results[0], "First result isn't a DataObject"
        assert_equal "image/jpeg", results[0].type["Content-Type"], "Content-Type not copied"
        assert_equal "5589", results[0].type["Content-ID"], "Content-ID not copied"
        assert_equal "25478", results[0].type["Object-ID"], "Object-ID not copied"
        assert_equal 241, results[0].data.size, "First object isn't 241 bytes in length"
    end

    def test_returns_single_entity_object_as_chunked_encoding_in_a_single_element_array
        @response.expects(:[]).with('content-type').at_least_once.returns("image/jpeg")
        @response.expects(:[]).with('Transfer-Encoding').at_least_once.returns("chunked")
        @response.expects(:[]).with('Object-ID').at_least_once.returns("25478")
        @response.expects(:[]).with('Content-ID').at_least_once.returns("5589")
        @response.expects(:body).returns("\000"*241)

        results = @rets.get_object("Property", "Photo", "392103:*")
        assert_equal 1, results.size, "Client parsed one object out of the request"
        assert_kind_of RETS4R::Client::DataObject, results[0], "First result isn't a DataObject"
        assert_equal "image/jpeg", results[0].type["Content-Type"], "Content-Type not copied"
        assert_equal "5589", results[0].type["Content-ID"], "Content-ID not copied"
        assert_equal "25478", results[0].type["Object-ID"], "Object-ID not copied"
        assert_equal 241, results[0].data.size, "First object isn't 241 bytes in length"
    end

    def test_yields_data_objects_to_block_and_returns_blocks_value
        @response.expects(:[]).with('content-type').at_least_once.returns("image/jpeg")
        @response.expects(:[]).with('Transfer-Encoding').at_least_once.returns("")
        @response.expects(:[]).with('Content-Length').at_least_once.returns(241)
        @response.expects(:[]).with('Object-ID').at_least_once.returns("25478")
        @response.expects(:[]).with('Content-ID').at_least_once.returns("5589")
        @response.expects(:body).returns("\000"*241)

        yielded_count = 0

        value = @rets.get_object("Property", "VRImage", "912:0") do |result|
            assert_kind_of RETS4R::Client::DataObject, result
            yielded_count += 1
            :return_value
        end

        assert_equal yielded_count, value
    end
    def test_correcly_handles_location_header_url
      @response.expects(:[]).with('content-type').at_least_once.returns("multipart/parallel; boundary='1231'")
      @response.expects(:body).returns(
"\r\n--1231\r\nContent-ID: 392103\r\nObject-ID: 1\r\nContent-Type: image/jpeg\r\nLocation: http://example.com/391203-1.jpg\r\n\r\n" +
"\000"*120 +
"\r\n--1231\r\nContent-ID: 392103\r\nObject-ID: 2\r\nContent-Type: image/gif\r\nLocation: http://example.com/391203-2.gif\r\n\r\n" +
"\000"*140 +
"\r\n--1231--"
      )
      results = @rets.get_object("Property", "Photo", "392103:*", true)

      assert_equal 'http://example.com/391203-1.jpg', results.first.info['Location'], "incorrect location"
      assert_equal 'http://example.com/391203-2.gif', results.last.info['Location'], "incorrect location"
    end
end
