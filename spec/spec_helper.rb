require 'simplecov'
SimpleCov.start do
  add_filter '.bundle'
  add_filter 'spec'
end

require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'taxonomy_parser'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com')
