#!/usr/bin/env ruby
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "."))
require 'test_helper'
require 'rets4r/response_document/search'

class TestResponseDocumentSearch < Test::Unit::TestCase
  def fixture(name)
    File.open("test/data/1.5/#{name}.xml").read
  end

  context 'RETS4R::ResponseDocument::Search' do
    setup { @doc = RETS4R::ResponseDocument::Search.parse(fixture('search_compact')) }
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
      should match_attributes(:success?, :reply_text).of { @doc }
      should('have reply_code') { assert_equal @doc.reply_code.to_s, subject.reply_code }
      should('have empty header') { assert_equal [], subject.header }
      should('have nil metadata') { assert_equal nil, subject.metadata }
      should('do everything else') do
        assert_equal ?\t, subject.delimiter
        assert_equal "\t", subject.ascii_delimiter
        assert_equal true, subject.maxrows?

        assert_equal 2, subject.response.length, 'response length should be 2'
        assert_equal "Datum1", subject.response[0]['First']
        assert_equal "Datum2", subject.response[0]['Second']
        assert_equal "Datum3", subject.response[0]['Third']
        assert_equal "Datum4", subject.response[1]['First']
        assert_equal "Datum5", subject.response[1]['Second']
        assert_equal "Datum6", subject.response[1]['Third']
      end
    end
  end
end
