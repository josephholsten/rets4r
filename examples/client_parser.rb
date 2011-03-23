#!/usr/bin/env ruby
# client_parser.rb: take a RETS XML Document and print how it looks
$:.unshift 'lib'
require 'rets4r'

xml = ARGF

transaction = ResponseDocument.safe_parse(xml).validate!.results
transaction.response.each {|row| puts row.inspect }