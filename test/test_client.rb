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
        assert_nothing_raised() { @rets.user_agent = 'ACK/2.1' }
        assert_equal('ACK/2.1', @rets.user_agent)

        assert_nothing_raised() { @rets.user_agent = 'SPRETS/0.1' }
        assert_nothing_raised() { @rets.request_method = 'GET' }

        assert_raise(RETS4R::Client::Unsupported) { @rets.rets_version = '1.4.0' }
        assert_nothing_raised() { @rets.rets_version = '1.5' }
        assert_equal("1.5", @rets.rets_version)
        assert_equal("RETS/1.5", @rets.get_header("RETS-Version"))
        assert_nothing_raised() { @rets.rets_version = '1.7' }
        assert_equal("RETS/1.7", @rets.get_header("RETS-Version"))

        assert_equal('SPRETS/0.1', @rets.user_agent)
        assert_equal('GET', @rets.request_method)
        assert_equal('1.7', @rets.rets_version)

        assert_nothing_raised() { @rets.request_method = 'POST' }

        assert_equal('POST', @rets.request_method)


        # Check that our changes were logged when in debug mode
        assert @logfile.length > 0
    end

    # Just to make sure that we're okay when we don't have a logger, we set it to nil and
    # make a change that would trigger a debug mode log.
    def test_without_logger
        @rets.logger = nil

        assert_nothing_raised() { @rets.request_method = 'GET' }
    end

    def test_content_type_parsing
        ct = 'multipart/parallel; boundary=cc2631bb.0165.3b32.8a7d.a8453f662101; charset=utf-8'

        results = @rets.process_content_type(ct)

        assert_equal('cc2631bb.0165.3b32.8a7d.a8453f662101', results['boundary'])
        assert_equal('multipart/parallel', results['content-type'])
        assert_equal('utf-8', results['charset'])
    end

    def test_performs_get_request
        assert_nothing_raised() {@rets.request_method = 'GET'}
        assert_equal('GET', @rets.request_method)

        http     = mock('http')
        response = mock('response')
        response.stubs(:to_hash).returns({})
        response.stubs(:code).returns('500')
        response.stubs(:message).returns('Move along, nothing to see here.')

        http.expects(:get).with('', {'User-Agent' => @rets.user_agent, 'RETS-Version' => "RETS/#{@rets.rets_version}", 'Accept' => '*/*'}).at_least_once.returns(response)
        http.expects(:post).never
        Net::HTTP.any_instance.expects(:start).at_least_once.yields(http)

        assert_raises(RETS4R::Client::HTTPError) {@rets.login('user', 'pass')}
    end

    def test_performs_post_request
        assert_nothing_raised() {@rets.request_method = 'POST'}
        assert_equal('POST', @rets.request_method)

        http     = mock('http')
        response = mock('response')
        response.stubs(:to_hash).returns({})
        response.stubs(:code).returns('500')
        response.stubs(:message).returns('Move along, nothing to see here.')

        http.expects(:post).with('', '', {'User-Agent' => @rets.user_agent, 'RETS-Version' => "RETS/#{@rets.rets_version}", 'Accept' => '*/*'}).at_least_once.returns(response)
        http.expects(:get).never
        Net::HTTP.any_instance.expects(:start).at_least_once.yields(http)

        assert_raises(RETS4R::Client::HTTPError) {@rets.login('user', 'pass')}
    end

    # FIXME: demo server is down, we need data to stub this
    # def test_search_without_query_should_not_raise_no_metho_error
    #     client = RETS4R::Client.new('http://demo.crt.realtors.org:6103/rets/login')
    #     client.login('Joe', 'Schmoe')
    #     begin
    #       client.search('', '', nil)
    #       # search_uri = URI.parse("http://demo.crt.realtors.org:6103/rets/search")
    #       # client.send :request, search_uri,
    #       #   {"Query"=>nil, "Format"=>"COMPACT", "Count"=>"0", "QueryType"=>"DMQL2", "Class"=>"", "SearchType"=>""}
    #     rescue Exception => e
    #       assert_not_equal "NoMethodError", e.class.to_s
    #     end
    # end

    def test_count

      logfile = StringIO.open
      rets    = RETS4R::Client.new(RETS_URL)
      rets.logger = Logger.new(logfile)
      rets.logger.level = Logger::DEBUG

      RETS4R::Client::Requester.any_instance.stubs(:request).returns(response = mock('response'))
      response.stubs(:body).returns(:body)
      RETS4R::Client::ResponseParser.any_instance.stubs(:parse_count).returns(:count)

      count = rets.count(:search_type, :class, :query)

      # assert_equal :search_url, search_url
      # assert_equal :search_type, data['SearchType']
      # assert_equal :class, data['Class']
      # assert_equal :query, data['Query']
      assert_equal :count, count
    end

    def test_count_returns_count
      RETS4R::Client::Requester.any_instance.stubs(:request).returns(response = mock('response'))
      response.stubs(:body).returns(:body)
      RETS4R::Client::ResponseParser.any_instance.stubs(:parse_count).returns(:count)
      rets = RETS4R::Client.new(RETS_URL)

      assert_equal :count, rets.count(:search_type, :class, :query)
    end

    def test_count_passes_request_params
      RETS4R::Client::Links.stubs(:from_login_url).returns(links = mock('links'))
      links.stubs(:search).returns(:search_url)
      expected_data = {'Query' => :query, 'Format' => 'COMPACT', 'Count' => '2', 'QueryType' => 'DMQL2', 'Class' => :class, 'SearchType' => :search_type}
      RETS4R::Client::Requester.any_instance.expects(:request).with(:search_url, expected_data, {}, 'GET', 2).returns(response = mock('response'))
      response.stubs(:body).returns(:body)
      RETS4R::Client::ResponseParser.any_instance.stubs(:parse_count).returns(:count)
      rets = RETS4R::Client.new(RETS_URL)

      rets.count(:search_type, :class, :query)
    end
    def test_count_with_options_passes_request_params
      RETS4R::Client::Links.stubs(:from_login_url).returns(links = mock('links'))
      links.stubs(:search).returns(:search_url)
      # note the extra option is merged in, with the key converted to a string
      expected_data = {'OPTION' => 'option', 'Query' => :query, 'Format' => 'COMPACT', 'Count' => '2', 'QueryType' => 'DMQL2', 'Class' => :class, 'SearchType' => :search_type}
      RETS4R::Client::Requester.any_instance.expects(:request).with(:search_url, expected_data, {}, 'GET', 2).returns(response = mock('response'))
      response.stubs(:body).returns(:body)
      RETS4R::Client::ResponseParser.any_instance.stubs(:parse_count).returns(:count)
      rets = RETS4R::Client.new(RETS_URL)

      rets.count(:search_type, :class, :query, 'OPTION' => :option)
    end
    # test_count_with_options
end
