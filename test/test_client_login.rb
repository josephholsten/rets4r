#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/client'

class TestClientLogin < Test::Unit::TestCase
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
        @response.stubs(:body).returns(:body)
        RETS4R::Client::ResponseParser.any_instance.stubs(:parse_key_value).returns(@results = mock("results"))
        @results.stubs(:success?).returns(true)
        @results.stubs(:response).returns(Hash.new)
        @results.stubs(:secondary_response=)
    end

    def teardown
        @logfile.close
    end

    def test_successful_login_yields_the_results_to_the_block
        @rets.expects(:request).with {|arg| arg.kind_of?(URI)}.returns(@response)
        RETS4R::Client::ResponseParser.any_instance.expects(:parse_key_value).returns(@results)
        @results.expects(:success?).returns(true)
        @rets.expects(:logout)

        in_block = false
        @rets.login("user", "pass") do |results|
            assert_equal @results, results
            in_block = true
        end

        assert in_block, "Block was never yielded to"
    end

    def test_logout_called_after_block_execution_if_block_raises
        assert_raises(CustomError) do
            @rets.expects(:logout)
            @rets.login("user", "pass") do |results|
                raise CustomError
            end
        end
    end

    def test_login_returns_the_blocks_value
        rval = @rets.login("user", "pass") do |results|
            :value
        end

        assert_equal :value, rval
    end

    def test_login_without_a_block_returns_the_results
        results = @rets.login("user", "pass")
        assert_equal @results, results
    end
end