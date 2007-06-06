$:.unshift File.join(File.dirname(__FILE__), "../..", "lib")

require 'rets4r/client'
require 'test/unit'
require 'stringio'
require 'logger'
require 'rubygems' rescue nil
require 'mocha'

module RETS4R
	class Client
		public :process_content_type
	end
	
	class TestClientGetMetadata < Test::Unit::TestCase
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
			@rets.stubs(:parse).returns(@results = mock("results"))
		end

		def teardown
			@logfile.close
		end
		
		def test_get_metadata_yields_the_results_if_given_a_block
			@rets.expects(:parse).returns(@results = mock("results"))
			
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
			@rets.stubs(:parse).returns(@results = mock("results"))
			@results.stubs(:success?).returns(true)
			@results.stubs(:response).returns(Hash.new)
			@results.stubs(:secondary_response=)
		end

		def teardown
			@logfile.close
		end

		def test_successful_login_yields_the_results_to_the_block
			@rets.expects(:request).with {|arg| arg.kind_of?(URI)}.returns(@response)
			@rets.expects(:parse).with(:body, RETS4R::Client::OUTPUT_RUBY).returns(@results)
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
	
	class TestClient < Test::Unit::TestCase
		RETS_PORT     = '9080'
		RETS_URL      = "http://localhost:#{RETS_PORT}"
		RETS_LOGIN    = 'login'
		RETS_PASSWORD = 'password'
		
		def setup
			@logfile = StringIO.open
			@rets    = RETS4R::Client.new(RETS_URL)
			@rets.logger = Logger.new(@logfile)
			@rets.logger.level = Logger::DEBUG
		end

		def teardown
			@logfile.close
		end
		
		def test_setup
			assert_nothing_raised() { @rets.set_user_agent('ACK/2.1') }
			assert_equal('ACK/2.1', @rets.user_agent)

			assert_nothing_raised() { @rets.user_agent = 'SPRETS/0.1' }
			assert_nothing_raised() { @rets.set_request_method('GET') }
			
			assert_raise(RETS4R::Client::Unsupported) { @rets.set_rets_version('1.4.0') }
			assert_nothing_raised() { @rets.set_rets_version('1.5') }
			
			assert_equal('SPRETS/0.1', @rets.get_user_agent)
			assert_equal('GET', @rets.get_request_method)
			assert_equal('1.5', @rets.get_rets_version)
			
			assert_nothing_raised() { @rets.request_method = 'POST' }
			
			assert_equal('POST', @rets.request_method)
			
			assert_nothing_raised() { @rets.set_parser_class(Client::Parser::REXML) }
			assert_raise(Client::Unsupported) { @rets.parser_class = MockParser }
			assert_nothing_raised() { @rets.set_parser_class(MockParser, true) }
			assert_equal(MockParser, @rets.parser_class)
			
			assert_nothing_raised() { @rets.set_output(RETS4R::Client::OUTPUT_RAW) }
			assert_equal(RETS4R::Client::OUTPUT_RAW, @rets.output)
			assert_nothing_raised() { @rets.output = RETS4R::Client::OUTPUT_RUBY }
			assert_equal(RETS4R::Client::OUTPUT_RUBY, @rets.get_output)
			
			# Check that our changes were logged when in debug mode
			assert @logfile.length > 0
		end
		
		# Just to make sure that we're okay when we don't have a logger, we set it to nil and
		# make a change that would trigger a debug mode log.
		def test_without_logger
			@rets.logger = nil
			
			assert_nothing_raised() { @rets.set_request_method('GET') }
		end
		
		def test_content_type_parsing
			ct = 'multipart/parallel; boundary=cc2631bb.0165.3b32.8a7d.a8453f662101; charset=utf-8'
			
			results = @rets.process_content_type(ct)

			assert_equal('cc2631bb.0165.3b32.8a7d.a8453f662101', results['boundary'])
			assert_equal('multipart/parallel', results['content-type'])
			assert_equal('utf-8', results['charset'])
		end
						
		class MockParser
		end
	end
end 