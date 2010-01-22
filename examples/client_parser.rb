#!/usr/bin/env ruby
$:.unshift 'lib'
require 'rubygems'
require 'rets4r'

xml = ARGF

parser = RETS4R::Client::ResponseParser.new
transaction = parser.parse_results(xml, 'COMPACT')
transaction.response.each {|row| puts row.inspect }