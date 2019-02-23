# frozen_string_literal: true
require "rubygems"
require "rspec"
require "rack"
require "coveralls"
Coveralls.wear!

require File.join(File.dirname(__FILE__), "..", "lib", "secure_cookies")
