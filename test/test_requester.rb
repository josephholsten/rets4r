#!/usr/bin/env ruby
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "."))
require 'test_helper'
class TestRequester < Test::Unit::TestCase
  context RETS4R::Client::Requester do
    setup do
      @uri = URI.parse('http://demo.crt.realtors.org:6103/rets/login')
      @requester = RETS4R::Client::Requester.new
    end
    context "when the last response contains a RETS-Session-ID cookie" do
      setup do
        body = <<-BODY
<?xml version="1.0"?>
<RETS ReplyCode="20203" ReplyText="User does not have access to Class named RES. Reference ID: 3fe82558-8015-4d9d-ab0c-776d9e4b5943" />
        BODY
        @response = stub('HTTPResponse', :code => '200', :body => body)
        @response.stubs(:get_fields).with('set-cookie').returns(['RETS-Session-ID=2qwiti55hq311j553ihivc3r; path=/'])
        Net::HTTP.any_instance.stubs(:get => @response )
        @requester.request(@uri)
      end
      context "the next request" do
        setup do
          @requester.request(@uri)
        end
        before_should "not set a RETS-Session-ID header" do
          Net::HTTP.any_instance.expects(:get).with do |anything,headers|
            assert_does_not_contain headers.keys, 'RETS-Session-ID'
            true
          end.returns(@response)
        end
        before_should "set a RETS-Session cookie" do
          Net::HTTP.any_instance.expects(:get).with(anything,has_entry('Cookie' => 'RETS-Session-ID=2qwiti55hq311j553ihivc3r')).returns(@response)
        end
      end
    end
  end
end
