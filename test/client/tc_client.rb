$:.unshift File.join(File.dirname(__FILE__), "../..", "lib")

require 'rets4r/client'
require 'test/unit'
require 'stringio'
require 'logger'

module RETS4R
	class Client
		public :process_content_type
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