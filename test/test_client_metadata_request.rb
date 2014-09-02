#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client'

module RETS4R
  class Client
    public :process_content_type
  end
end

class TestClientMetadataRequest < Minitest::Test
  RETS_PORT     = '9080'
  RETS_URL      = "http://localhost:#{RETS_PORT}"
  RETS_LOGIN    = 'login'
  RETS_PASSWORD = 'password'

  class CustomError < StandardError; end

  def setup
      @logfile = StringIO.open
      @response = Object.new
      @response.stubs(:body).returns(:body)
      RETS4R::Client::Requester.any_instance.stubs(:request).returns(@response)
      @rets = RETS4R::Client.new(RETS_URL)
      @rets.stubs(:request).returns(@response)
      @rets.logger = Logger.new(@logfile)
      @rets.logger.level = Logger::DEBUG
      @response = mock("response")
      @rets.stubs(:parse).returns(@results = mock("results"))
      RETS4R::Client::ResponseParser.any_instance.stubs(:parse_metadata).returns(@results = mock("results"))
  end

  def teardown
      @logfile.close
  end

  def test_get_metadata_yields_the_results_if_given_a_block
      in_block = false
      @rets.get_metadata do |results|
          in_block = true
          assert_equal @results, results
      end

      assert in_block, "Block was never yielded to"
  end

  def test_get_metadata_returns_the_metadata_when_no_block_given
      rval = @rets.get_metadata

      assert_equal @results, rval
  end

  def test_get_metadata_returns_the_blocks_value_when_given_a_block
      rval = @rets.get_metadata do |results|
          :block_value
      end

      assert_equal :block_value, rval
  end
end
