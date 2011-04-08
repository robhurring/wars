require 'bundler/setup'
Bundler.require :default

require './lib/helpers'
require './lib/core_ext'
require './lib/facebook'

DatabaseAuth = YAML::load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))

ActiveRecord::Base.configurations = DatabaseAuth
ActiveRecord::Base.logger = Logger.new(File.join('log', 'database.log'))
ActiveRecord::Base.establish_connection ENV['RACK_ENV']

require './lib/wars/wars'