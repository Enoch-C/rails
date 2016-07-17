  Spree::Admin::OrdersController.class_eval do
    before_action :load_promoters_data, only: [:index]

    def load_promoters_data
      @promoters = Spree::Promoter.order(:email)
    end

    def labels
      load_order
    end

    def index
      params[:q] ||= {}
      params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
      params[:q][:created_at_gt] ||= '2016-07-11'
      @show_only_completed = params[:q][:completed_at_not_null] == '1'
      params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
      params[:q][:completed_at_not_null] = '' unless @show_only_completed

      # As date params are deleted if @show_only_completed, store
      # the original date so we can restore them into the params
      # after the search
      created_at_gt = params[:q][:created_at_gt]
      created_at_lt = params[:q][:created_at_lt]

      params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

      if params[:q][:created_at_gt].present?
        params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
      end

      if params[:q][:created_at_lt].present?
        params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
      end

      if @show_only_completed
        params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
        params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
      end

      @search = Spree::Order.preload(:user).accessible_by(current_ability, :index).ransack(params[:q])

      # lazy loading other models here (via includes) may result in an invalid query
      # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
      # see https://github.com/spree/spree/pull/3919

      @labels = false
      if params["xls"]
        @orders = @search.result(distinct: true).
          page(params[:page]).
          per("9999999")
        combined_line_items
      elsif params["labels"]
        @labels = true
        @orders = @search.result(distinct: true).
          page(params[:page]).
          per("9999999")
      else
        @orders = @search.result(distinct: true).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end
      # Restore dates
      params[:q][:created_at_gt] = created_at_gt
      params[:q][:created_at_lt] = created_at_lt
    end

    def combined_line_items
      combined_line_items = {}
      dir = "report/daily"

      pdf = Prawn::Document.new(
      :margin => 0,
      :page_layout => :landscape
      )
      first_page = true

      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      shipbook = Spreadsheet.open 'report/template_shipping.xls'
      shipsheet = shipbook.worksheet 0
      addressbook = Spreadsheet::Workbook.new
      addresssheet = addressbook.create_worksheet
      addresssheet_row = 0
      addresssheet.row(addresssheet_row).push "申报品名", "品牌", "数量", "运单号", "重量", "收货人", "电话", "国家", "省份", "城市", "地址"

      @orders.each do |order|
        if order.ship_address.country.name == "China"
          pdf.start_new_page unless first_page
          pdf.image "report/letter.jpg", :width => 792, :height => 612
          pdf.font("report/Lantinghei-SC-Demibold.ttf", :size => 8) do
            pdf.draw_text order.ship_address.lastname + order.ship_address.firstname, :at => [86, 415]
          end
          pdf.font("report/Lantinghei-SC-Demibold.ttf", :size => 7) do
            pdf.draw_text Rails.application.config.customer_service_wechat[0], :at => [287, 305]
          end
          first_page = false

          addresssheet_row += 1
          addresssheet.row(addresssheet_row).push "Cool Choice 30-Pack", "Cool Choice", "#{order.item_count}", "#{order.number}", "#{order.item_count * 0.5}", "#{order.ship_address.lastname}#{order.ship_address.firstname}", "#{order.ship_address.phone}", "#{order.ship_address.country.name}", "#{order.ship_address.state.name}", "#{order.ship_address.city}", "#{order.ship_address.address2}#{order.ship_address.address1}"
        end
        shipsheet[0,4] = order.completed_at.in_time_zone('America/Los_Angeles').to_date.to_s
        shipsheet[1,0] = "Order #{order.number}"
        ship_address = order.ship_address
        shipsheet[4,1] = "#{ship_address.firstname} #{ship_address.lastname}"
        shipsheet[5,1] = "#{ship_address.address1}"
        if ship_address.address2
          shipsheet[6,1] = "#{ship_address.address2}"
          shipsheet[7,1] = "#{ship_address.city}, #{ship_address.state.name}, #{ship_address.zipcode}"
          shipsheet[8,1] = "#{ship_address.country.name}"
        else
          shipsheet[6,1] = "#{ship_address.city}, #{ship_address.state.name}, #{ship_address.zipcode}"
          shipsheet[7,1] = "#{ship_address.country.name}"
        end
        row = 12
        row_format = shipsheet.row(row).default_format
        order.line_items.each do |line_item|
          shipsheet.row(row).default_format = row_format
          shipsheet[row,0] = line_item.variant.product.name + " (" + line_item.variant.options_text + ")"
          shipsheet[row,2] = line_item.quantity.to_s + ' ' + line_item.variant.sku[3]
          shipsheet[row,3] = line_item.single_money.to_html
          shipsheet[row,4] = line_item.display_amount.to_html
          row += 1
          key = line_item.sku.split(//).last(6).join
          unless combined_line_items.has_key?(key)
          combined_line_items[key] = [0,0,0]
          end
          case line_item.sku[3]
          when 'm'
            combined_line_items[key][0] += line_item.quantity
          when 'w'
            combined_line_items[key][1] += line_item.quantity
          when 'd'
            combined_line_items[key][2] += line_item.quantity
          end
        end

        shipsheet[31,4] = Spree::Money.new(order.shipments.to_a.sum(&:cost), currency: order.currency).to_html
        shipsheet[32,4] = order.display_total.to_html

        filepath = "report/daily/#{order.number}-#{Time.now.to_date}.xls"
        File.delete(filepath) if File.exist?(filepath)
        shipbook.write filepath
      end

      addressbook.write "#{dir}/addresses-#{Time.now.to_date}.xls"
      pdf.render_file "#{dir}/letters-#{Time.now.to_date}.pdf"
      retains = [4, 1, 0]
      book = Spreadsheet.open 'report/template_blend.xls'
      sheet1 = book.worksheet 0
      sheet2 = book.worksheet 1
      sheet3 = book.worksheet 2
      sheet4 = book.worksheet 3

      combined_line_items.keys.each do |key|
        sheet1[3,3] = Time.now.to_date.to_s
        sheet2[3,3] = Time.now.to_date.to_s
        sheet3[3,3] = Time.now.to_date.to_s
        sheet4[3,3] = Time.now.to_date.to_s
        sheet1[5,3] = key
        sheet2[5,3] = key
        sheet3[5,3] = key
        sheet4[5,3] = key
        sheet1[5,8] = 6 * (combined_line_items[key][0] * (30+retains[0]) + combined_line_items[key][1] * (7+retains[1]) + combined_line_items[key][2] * (1+retains[2]))
        sheet2[5,8] = 6 * (combined_line_items[key][0] * (30+retains[0]))
        sheet3[5,8] = 6 * (combined_line_items[key][1] * (7+retains[1]))
        sheet4[5,8] = 6 * (combined_line_items[key][2] * (1+retains[2]))
        sheet1[6,8] = "#{combined_line_items[key][0]}m + #{combined_line_items[key][1]}w + #{combined_line_items[key][2]}d"
        sheet2[6,8] = combined_line_items[key][0].to_i
        sheet3[6,8] = combined_line_items[key][1].to_i
        sheet4[6,8] = combined_line_items[key][2].to_i
        sheet1[9,1] = "BP0#{key[0,2]}"
        sheet1[10,1] = "BP0#{key[2,2]}"
        sheet1[11,1] = "BP0#{key[4,2]}"
        sheet1[9,2] = Rails.application.config.function_list[key[0,2].to_i-1] + " Blend"
        sheet1[10,2] = Rails.application.config.function_list[key[2,2].to_i-1] + " Blend"
        sheet1[11,2] = Rails.application.config.function_list[key[4,2].to_i-1] + " Blend"

        filepath = "report/daily/#{key}-#{Time.now.to_date}.xls"
        File.delete(filepath) if File.exist?(filepath)
        book.write filepath
      end

      filename = "#{Time.now.to_date}.zip"
      temp_file = Tempfile.new(filename)
      begin
        Zip::OutputStream.open(temp_file) { |zos| }
        Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
          Dir.foreach(dir) do |item|
            item_path = "#{dir}/#{item}"
            zip.add( item,item_path) if File.file?item_path
          end
        end
        zip_data = File.read(temp_file.path)
        send_data(zip_data, :type => 'application/zip', :filename => filename)
      ensure
        temp_file.close
        temp_file.unlink
        FileUtils.rm_rf(Dir.glob("#{dir}/*"))
      end
    end

  end
