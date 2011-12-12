#!/usr/bin/env ruby -w
testdir = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/response_document/search'

class TestResponseDocumentSearch < Test::Unit::TestCase
  context 'RETS4R::ResponseDocument::Search' do
    setup { @doc = RETS4R::ResponseDocument::Search.parse(fixture('search_compact.xml').open) }
    subject { @doc }
    context 'when exposing the old transaction API' do
      should('have max_rows') { assert subject.max_rows? }
      should('have delimiter') { assert_equal "\t", subject.delimiter }
      should('have success') { assert subject.success? }
      should('have reply_text') { assert_equal "SUCCESS", subject.reply_text }
    end

    should('have columns') { assert_equal %w(First Second Third), subject.columns }
    context 'enumerable' do
      should('to_a') do
        listings = subject.to_a
        assert_equal({"Third"=>"Datum3", "Second"=>"Datum2", "First"=>"Datum1"}, listings[0])
        assert_equal({"Third"=>"Datum6", "Second"=>"Datum5", "First"=>"Datum4"}, listings[1])
      end
    end

    # should('have nil metadata') { assert_equal nil, subject.metadata }
    # should act like a transaction
    context 'as transaction' do
      setup { @transaction = @doc.to_transaction }
      subject { @transaction }

      should match_attributes(:success?, :reply_text, :max_rows?, :ascii_delimiter).of { @doc }
      should('have empty header') { assert_equal [], subject.header }
      should('have nil metadata') { assert_equal nil, subject.metadata }

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
        should('have #maxrows?') { assert_equal true, subject.maxrows? }
        should('have string #reply_code') { assert_equal @doc.reply_code.to_s, subject.reply_code }
      end
    end
  end
end
