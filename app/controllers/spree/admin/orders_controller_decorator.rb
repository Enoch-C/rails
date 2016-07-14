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
      @orders = @search.result(distinct: true).
        page(params[:page]).
        per(params[:per_page] || Spree::Config[:orders_per_page])

      # Restore dates
      params[:q][:created_at_gt] = created_at_gt
      params[:q][:created_at_lt] = created_at_lt

      # @orders = @search.result(distinct: true).
      #   page(params[:page]).
      #   per("999999999")
      # combined_line_items
    end

    def combined_line_items
      combined_line_items = {}
      @orders.each do |order|
        order.line_items.each do |line_item|
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
      end

      retains = [4, 1, 0]

      key = "010203"
      # combined_line_items.each do |key|
        book = Spreadsheet.open 'report/template.xls'
        sheet1 = book.worksheet 0
        sheet1[3,3] = Time.now.to_date.to_s
        sheet1[5,3] = key
        sheet1[5,8] = 6 * (combined_line_items[key][0] * (30+retains[0]) + combined_line_items[key][1] * (7+retains[1]) + combined_line_items[key][2] * (1+retains[2]))
        sheet1[6,8] = "#{combined_line_items[key][0]}m + #{combined_line_items[key][1]}w + #{combined_line_items[key][2]}d"
        sheet1[9,1] = "BP0#{key[0,2]}"
        sheet1[10,1] = "BP0#{key[2,2]}"
        sheet1[11,1] = "BP0#{key[4,2]}"
        sheet1[9,2] = Rails.application.config.function_list[key[0,2].to_i] + " Blend"
        sheet1[10,2] = Rails.application.config.function_list[key[2,2].to_i] + " Blend"
        sheet1[11,2] = Rails.application.config.function_list[key[4,2].to_i] + " Blend"
        # sheet1[9,5] = sheet1[5,8]/3
        # sheet1[10,5] = sheet1[5,8]/3
        # sheet1[11,5] = sheet1[5,8]/3

        filepath = "report/daily/#{key} - #{Time.now.to_date}.xls"
        File.delete(filepath) if File.exist?(filepath)
        book.write filepath
      # end

    end

    def xlt_summary
      book = Spreadsheet::Workbook.new
      summary = book.create_worksheet :name => 'Summary'
      pos_row = 0
      @orders.each do |order|
        summary.row(pos_row).push order.number, order.completed_at, order.total
        pos_row += 1
        order.line_items.each do |line_item|
          summary.row(pos_row).push line_item.sku, line_item.quantity
          pos_row += 1
        end
      end
      book.write 'excel-file.xls'
      # book = Spreadsheet.open 'CCPersonalizedBlendBR8.08.16.xls'
      # book.worksheets.each do |sheet|
      #   sheet.each do |row|
      #     row.each do |cell|
      #       puts cell
      #     end
      #   end
      # end
    end

  end
