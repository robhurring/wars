%w{rubygems benchmark logger yaml pp}.each{ |lib| require lib }

task :environment do
  require './lib/environment'
end

namespace :db do
  desc "Migrate the database"  
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )  
  end  
end

namespace :wars do
  
  desc 'List of Products'
  task :products => :environment do
    puts "%-20s %-10s %-10s" % ['Product Name', '$ Min', '$ Max']
    Wars::Product.all.each do |product|
      puts "%-20s %-10d %-10d" % [product.name, product.price_range.min, product.price_range.max]
    end
  end
  
  desc 'List of Equipment'
  task :equipment => :environment do
    puts "%-20s %-8s %-8s %-10s %-6s %s" % ['Product Name', 'Limit', 'Price', 'Adds', 'Amount', 'Disposable?']
    Wars::Equipment.all.each do |equipment|
      puts "%-20s %-8d %-8d %-10s %-6d %s" % [equipment.name, equipment.limit, equipment.price, equipment.adds, equipment.amount, (equipment.disposable? ? 'Yes' : 'No')]
    end
  end
  
end