#!/usr/bin/env ruby -w
testdir = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/response_document/base'
require 'rets4r/response_document/search'

class TestResponseDocumentBase < Test::Unit::TestCase
  def fixture(name)
    File.open("test/data/1.5/#{name}.xml").read
  end

  context "normal doc" do
    setup do
      @doc = RETS4R::ResponseDocument::Base.parse(fixture('search_compact'))
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
    context 'parse_results' do
      setup { @transaction = @doc.parse_results }
      subject { @transaction }

      should match_attributes(:success?, :reply_text, :max_rows?).of { @doc }
      should('have ascii_delimiter') { assert_equal "\t", subject.ascii_delimiter }
      should('have header') { assert_equal [], subject.header }
      should('have metadata') { assert_equal nil, subject.metadata }

      context 'response' do
        subject { @transaction.response }
        should('be length 2') { assert_equal 2, subject.length }
        should('have first row') { assert_equal({"Third"=>"Datum3", "Second"=>"Datum2", "First"=>"Datum1"}, subject[0]) }
        should('have second row') { assert_equal({"Third"=>"Datum6", "Second"=>"Datum5", "First"=>"Datum4"}, subject[1]) }
      end
      context 'deprecated methods' do
        setup { $VERBOSE = false }
        teardown { $VERBOSE = true }
        should('have integer #delimiter') { assert_equal ?\t, subject.delimiter }
        should('have #maxrows?') { assert_equal @doc.max_rows?, subject.maxrows? }
        should('have string #reply_code') { assert_equal @doc.reply_code.to_s, subject.reply_code }
      end
    end
    context :to_transaction do
      setup { @transaction = @doc.to_transaction }
      subject { @transaction }
      should match_attributes(:success?, :reply_text, :max_rows?).of { @doc }
      should('set doc') { assert_equal @doc, subject.doc }
      context 'with block' do
        setup { @transaction = @doc.to_transaction { :inside_block }}
        should 'set response from block' do
          assert_equal :inside_block, @transaction.response
        end
      end
      context 'deprecated methods' do
        setup { $VERBOSE = false }
        teardown { $VERBOSE = true }
        should('have #maxrows?') { assert_equal @doc.max_rows?, subject.maxrows? }
        should('have string #reply_code') { assert_equal @doc.reply_code.to_s, subject.reply_code }
      end
    end
  end
  context 'empty doc' do
    setup do
      @doc = RETS4R::ResponseDocument::Base.parse(fixture('empty'))
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
      @doc = RETS4R::ResponseDocument::Base.parse(fixture('error'))
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
      @doc = RETS4R::ResponseDocument::Base.parse(fixture('login'))
    end
    should 'parse_key_value' do
      transaction = @doc.parse_key_value

      assert_equal(true, transaction.success?)
      assert_equal('srealtor,1,11,11111', transaction.response['User'])
      assert_equal('/rets/Login', transaction.response['Login'])
    end
  end
end
