#!/usr/bin/env ruby
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "."))
require 'test_helper'
require 'rets4r/response_document'
class TestResponseDocument < Test::Unit::TestCase
  def fixture(name)
    File.open("test/data/1.5/#{name}.xml").read
  end

  context "normal doc" do
    setup do
      @doc = RETS4R::ResponseDocument.parse(fixture('search_compact'))
    end
    should 'have max_rows' do
      assert @doc.max_rows?
    end
    should 'have reply text' do
      assert_equal 'SUCCESS', @doc.reply_text
    end
    should 'have reply code' do
      assert_equal 0, @doc.reply_code
    end
    should 'be success' do
      assert @doc.success?
    end
    should 'be rets' do
      assert @doc.rets?
    end
    should 'be valid' do
      assert @doc.valid?
    end
    should 'not be invalid' do
      assert !@doc.invalid?
    end
    should 'not be in error' do
      assert !@doc.error?
    end
    should 'parse count' do
      assert_equal 4, @doc.parse_count.response
    end
    should 'have count' do
      assert_equal 4, @doc.count
    end
    should 'convert to rexml' do
      assert_kind_of REXML::Document, @doc.to_rexml
    end
    should 'validate!' do
      assert_equal @doc, @doc.validate!
    end
    should 'parse_results' do
      transaction = @doc.parse_results

      assert_equal @doc.success?, transaction.success?
      assert_equal @doc.reply_code.to_s, transaction.reply_code
      assert_equal @doc.reply_text, transaction.reply_text
      assert_equal [], transaction.header

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
    end
    context :to_transaction do
      setup { @transaction = @doc.to_transaction }
      should 'set reply code' do
        assert_equal @doc.reply_code.to_s, @transaction.reply_code
      end
      should 'set reply_text' do
        assert_equal @doc.reply_text, @transaction.reply_text
      end
      context 'with block' do
        setup { @transaction = @doc.to_transaction { :inside_block }}
        should 'set response from block' do
          assert_equal :inside_block, @transaction.response
        end
      end
    end
  end
  context 'empty doc' do
    setup do
      @doc = RETS4R::ResponseDocument.parse(fixture('metadata'))
    end
    should 'not be rets' do
      assert !@doc.rets?
    end
    should 'not be valid' do
      assert @doc.invalid?
    end
    should 'raise in validate!' do
      assert_raises(RETS4R::Client::RETSException) do
        @doc.validate!
      end
    end
  end
  context 'error doc' do
    setup do
      @doc = RETS4R::ResponseDocument.parse(fixture('error'))
    end
    should 'not be valid' do
      assert @doc.invalid?
    end
    should 'raise in validate!' do
      assert_raises(RETS4R::Client::InvalidResourceException) do
        @doc.validate!
      end
    end
    should 'be error' do
      assert @doc.error?
    end
    should 'not have max rows' do
      assert !@doc.max_rows?
    end
    should 'have reply code' do
      assert_equal 20400, @doc.reply_code
    end
  end
  context 'login doc' do
    setup do
      @doc = RETS4R::ResponseDocument.parse(fixture('login'))
    end
    should 'parse_key_value' do
      transaction = @doc.parse_key_value

      assert_equal(true, transaction.success?)
      assert_equal('srealtor,1,11,11111', transaction.response['User'])
      assert_equal('/rets/Login', transaction.response['Login'])
    end
  end
end
