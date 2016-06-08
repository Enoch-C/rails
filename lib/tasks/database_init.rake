require 'ffaker'
require 'pathname'
require 'spree/sample'

namespace :database_init do
  desc 'Loads coolchoice data'
  task :load => :environment do
    if ARGV.include?("db:migrate")
      puts %Q{
Please run db:migrate separately from database_init:load.

Running db:migrate and database_init:load at the same time has been known to
cause problems where columns may be not available during sample data loading.

Migrations have been run. Please run "rake database_init:load" by itself now.
      }
      exit(1)
    end

    Spree::Sample.load_sample("ccshipping_categories")
    Spree::Sample.load_sample("ccshipping_methods")
    Spree::Sample.load_sample("ccpromotion_categories")
    Spree::Sample.load_sample("cctax_rates")
    Spree::Sample.load_sample("ccstock")
    Spree::Sample.load_sample("ccstore_credit_categories")
    Spree::Sample.load_sample("ccvariants")
    Spree::Role.find_or_create_by(name: 'shipping')

  end

end
