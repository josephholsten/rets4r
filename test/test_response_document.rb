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
    context :to_transaction do
      setup { @transaction = @doc.to_transaction }
      should 'set reply code' do
        assert_equal @doc.reply_code.to_s, @transaction.reply_code
      end
      should 'set reply_text' do
        assert_equal @doc.reply_text, @transaction.reply_text
      end
      context 'with block' do
        setup { @transaction = @doc.to_transaction {|doc| @inner_doc = doc; :inside_block }}
        should 'set response from block' do
          assert_equal :inside_block, @transaction.response
        end
        should 'yield doc' do
          assert_equal @doc, @inner_doc
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
end
