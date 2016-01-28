require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start 'rails'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'taxonomy_parser'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)