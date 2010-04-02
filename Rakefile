%w{rubygems benchmark logger yaml pp}.each{ |lib| require lib }

task :environment do
  require 'lib/environment'
end

namespace :db do
  desc "Migrate the database"  
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )  
  end  
end