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

  desc 'add inventory'
  task :inventory => :environment do
    func1_id = Spree::OptionType.find_by_name!("func1").id
    func2_id = Spree::OptionType.find_by_name!("func2").id
    func3_id = Spree::OptionType.find_by_name!("func3").id
    Rails.application.config.product_list.each_with_index do |product_name, product_index|
      Rails.application.config.function_list.combination(3).each_with_index do |funcs, index|
        sku = ""
        case product_index
        when 0
          sku = "ccsd3f"
        when 1
          sku = "ccsw3f"
        when 2
          sku = "ccsm3f"
        end
        sku = sku + format('%02d', Rails.application.config.function_list.index(funcs[0])+1) + format('%02d', Rails.application.config.function_list.index(funcs[1])+1) + format('%02d', Rails.application.config.function_list.index(funcs[2])+1)
        v = Spree::Variant.find_by(sku: sku)
        if v
          v.stock_items.each do |stock|
            stock.set_count_on_hand(999999)
          end
          puts "#{sku} saved"
        end
      end
    end
  end

end
