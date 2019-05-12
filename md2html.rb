#!/usr/bin/env ruby
require 'pp'
require 'net/http'
require 'rdiscount'

markdown= RDiscount.new(File.read(ARGV[0]))
puts markdown.to_html
