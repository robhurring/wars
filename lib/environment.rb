gem 'sinatra', '=1.0'
gem 'activesupport', '=2.3.5'
gem 'activerecord', '=2.3.5'
gem 'sanitize', '=1.2.1'
gem 'nokogiri', '=1.4.1' # dependency of sanitize
gem 'oauth2'
gem 'httparty'

require 'sinatra/base'
require 'active_support'
require 'active_record'
require 'rack-flash'
require 'lib/helpers'
require 'lib/core_ext'
require 'sanitize'

DatabaseAuth = YAML::load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))

ActiveRecord::Base.configurations = DatabaseAuth
ActiveRecord::Base.logger = Logger.new(File.join('log', 'database.log'))
ActiveRecord::Base.establish_connection ENV['RACK_ENV']

require 'lib/wars/wars'