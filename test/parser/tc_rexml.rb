$:.unshift File.join(File.dirname(__FILE__), "../..", "lib")

require 'test/unit'
require 'rets4r/client/parsers/response_parser'
require 'test_parser'

module RETS4R
	class Client		
		class TestRParser < Test::Unit::TestCase
			include TestParser
			
			def setup
				@parser = ResponseParser.new
			end
		end
	end
end
