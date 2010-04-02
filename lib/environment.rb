gem 'sinatra', '=1.0'
gem 'activesupport', '=2.3.5'
gem 'activerecord', '=2.3.5'

require 'sinatra/base'
require 'active_support'
require 'active_record'
require 'rack-flash'
require 'lib/helpers'

ActiveRecord::Base.configurations = {
  'development' => {
    'adapter' => 'mysql',
    'host' => 'localhost',
    'user' => 'root', 
    'pass' => '',
    'database' => 'wars'
  }
}

ActiveRecord::Base.logger = Logger.new(File.join('log', 'database.log'))
ActiveRecord::Base.establish_connection ENV['RACK_ENV']

require 'lib/wars/wars'