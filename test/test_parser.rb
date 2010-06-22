$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'test/unit'
require 'rets4r'

module RETS4R
    class Client
        class TestParser < Test::Unit::TestCase
            def setup
                @parser = ResponseParser.new
            end

            DATA_DIR = 'test/data/1.5/'

            def load_xml_from_file(file_name)
                xml = ''

                File.open(file_name) do |file|
                    file.each do |line|
                        xml << line
                    end
                end

                xml
            end

            def parse_to_transaction(xml_file_name)
                @parser.parse_key_value(load_xml_from_file(xml_file_name))
            end

            # Test Cases

#           TODO: verify test_search_compact header, metadata
            def test_search_compact
                xml = load_xml_from_file("#{DATA_DIR}search_compact.xml")
                transaction = @parser.parse_results(xml, 'COMPACT')

                assert_equal true, transaction.success?, "transaction should be successful"
                assert_equal '0', transaction.reply_code
                assert_equal 'SUCCESS', transaction.reply_text
                assert_equal [], transaction.header
                # XXX: this used to say, why?
#                assert_equal false, transaction.header.empty?

                assert_equal nil, transaction.metadata

                assert_equal ?\t, transaction.delimiter
                assert_equal "\t", transaction.ascii_delimiter
                assert_equal true, transaction.maxrows?

                assert_equal 2, transaction.response.length, 'response length should be 2'
                assert_equal "Datum1", transaction.response[0]['First']
                assert_equal "Datum2", transaction.response[0]['Second']
                assert_equal "Datum3", transaction.response[0]['Third']
                assert_equal "Datum4", transaction.response[1]['First']
                assert_equal "Datum5", transaction.response[1]['Second']
                assert_equal "Datum6", transaction.response[1]['Third']

                # Check for compatibility
                assert_equal transaction.data, transaction.response

                assert_equal nil, transaction.secondary_response
            end

            def test_unescaped_search_compact
              assert_raise(REXML::ParseException) do
                @parser.parse_key_value(load_xml_from_file("#{DATA_DIR}search_unescaped_compact.xml"))
              end
            end

            def test_invalid_search_compact
                assert_raise(REXML::ParseException) do
                  @parser.parse_key_value(load_xml_from_file("#{DATA_DIR}search_unescaped_compact.xml"))
                end
            end

            def test_login_results
                transaction = parse_to_transaction("#{DATA_DIR}login.xml")

                assert_equal(true, transaction.success?)
                assert_equal('srealtor,1,11,11111', transaction.response['User'])
                assert_equal('/rets/Login', transaction.response['Login'])
            end

            def test_error_results
                xml = load_xml_from_file("#{DATA_DIR}error.xml")

                exception = assert_raise(InvalidResourceException) do
                  @parser.parse_object_response(xml)
                end

                assert_equal('20400 - Invalid Invalidness.', exception.message)
            end
        end
    end
end
