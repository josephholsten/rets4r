$:.unshift File.join(File.dirname(__FILE__), "../..", "lib")

module RETS4R
    class Client

=begin

        Provides a set of parser tests that can be extend for each specific parser type.

        Usage:

            module TestMyParser < Test::Unit::TestCase
                include TestParser

                def setup
                    @parser = MyParser.new
                end
            end

=end

        module TestParser
            DATA_DIR = 'test/data/1.5/'

            def setup
                # To be overridden. Must set @parser with a valid parser object
            end

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

#           FIXME
#            def test_search_compact
##transaction = parse_to_transaction("#{DATA_DIR}search_compact.xml")
#                xml = load_xml_from_file("#{DATA_DIR}search_compact.xml")
##transaction = @parser.parse_object_response(xml)
#                transaction = @parser.parse_results(xml, 'COMPACT')
#
#                assert_equal(true, transaction.success?)
#                assert_equal(nil, transaction.response)
#                assert_equal(false, transaction.header.empty?)
#                assert_equal(2, transaction.data.length)
#                assert_equal(transaction.header.length, transaction.data[0].length)
#                assert_equal(4, transaction.count)
#                assert_equal(9, transaction.delimiter)
#                assert_equal("\t", transaction.ascii_delimiter)
#            end

#           FIXME
#            def test_unescaped_search_compact
#                transaction = parse_to_transaction("#{DATA_DIR}search_unescaped_compact.xml")

#                # (We should be able to recover automatically from this)
#                assert_equal(true, transaction.success?)
#                assert_equal(nil, transaction.response)
#                assert_equal(false, transaction.header.empty?)
#                assert_equal(2, transaction.data.length)
#                assert_equal(transaction.header.length, transaction.data[0].length)
#                assert_equal(4, transaction.count)
#            end

#           FIXME
#            def test_invalid_search_compact
#                assert_raise(ParserException) do
#                    parse_to_transaction("#{DATA_DIR}invalid_compact.xml")
#                end
#            end

            def test_login_results
                transaction = parse_to_transaction("#{DATA_DIR}login.xml")

                assert_equal(true, transaction.success?)
                assert_equal('srealtor,1,11,11111', transaction.response['User'])
                assert_equal('/rets/Login', transaction.response['Login'])
            end

=begin These were salvaged from the old parser test case.

#           FIXME
            def test_metadata_results
                trans = parse_to_transaction("test/client/data/metadata-full.xml")

                assert_equal(true, trans.success?)
                assert_equal(605, trans.data.length)

                #assert_equal('METADATA-SYSTEM', trans.data[0].type)
            end
=end

            def test_error_results
                xml = load_xml_from_file("#{DATA_DIR}error.xml")

                exception = assert_raise(InvalidResourceException) do
                  @parser.parse_object_response(xml)
                end

                assert_equal('20400 - Invalid Invalidness.', exception.message)
            end

#           FIXME
#            def test_parse_compact_line
#                results = @parser.parse_compact_line("    1    2    3    ")
#
#                assert_equal 3, results.size
#                assert_equal '1', results[0]
#                assert_equal '2', results[1]
#                assert_equal '3', results[2]
#            end

#           FIXME
#            def test_parse_data_should_ignore_empty_header_fields
#                header = ["", "1", "2", "3"]
#                data   = "        1    2    3    "
#
#                results = @parser.parse_data(data, header)
#
#                assert_nil results[""]
#                assert_equal 3, results.size
#            end
        end
    end
end
