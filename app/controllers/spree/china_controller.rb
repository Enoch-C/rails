module Spree
  class ChinaController < Spree::StoreController
    before_action :ensure_stripe_checkout, only: [:complete]
    skip_before_filter  :verify_authenticity_token

    def index
    end

    def login
      @order = Spree::Order.new

      variant = nil
      if params[:line_item][:variant_id]
        variant = Spree::Variant.find(params[:line_item][:variant_id])
      elsif params[:line_item][:sku]
        variant = Spree::Variant.find_by_sku(params[:line_item][:sku])
      end

      @line_item = @order.contents.add(
          variant,
          params[:line_item][:quantity] || 1,
          nil || {}
      )

      if @line_item.errors.empty?
        respond_with(@line_item, status: 201, default_template: :show)
      else
        invalid_resource!(@line_item)
      end

      @line_item.save!
      @order.state = "address"
      @order.save!
    end

    def checkout
      phone = "86" + params["mobile"]
      user = Spree::User.find_or_create_by("email": "#{phone}@coolchoice.com")
      user.password = user.email + "3?~0vo"
      user.save!
      @order = Spree::Order.find(params[:id])
      @order.associate_user!(user)
      @order.save!
      @province = provinces.invert
    end

    def pay
      @order = Spree::Order.find(params[:id])
      name = params["name"]
      state = provinces[params["province"].to_sym]

      address = Spree::Address.new
      address.firstname = name[1,name.size-1]
      address.lastname = name[0]
      address.address1 = params["street"]
      address.address2 = params["sub"]
      address.phone = @order.user.email[0, @order.user.email.size - 15]
      address.city = params["city"]
      address.zipcode = "110000"
      address.state_id = Spree::State.find_by_name(state).id
      address.country_id = Spree::Country.find_by_name("China").id
      unless address.same_as?(@order.bill_address)
        address.save
        @order.bill_address_id = address.id
        @order.ship_address_id = address.id
      end
      @order.update_line_item_prices!
      @order.create_tax_charge!
      @order.persist_user_address!

      packages = @order.shipments.map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      @order.state = "delivery"
      @order.create_proposed_shipments
      @order.send(:ensure_available_shipping_rates)
      @order.set_shipments_cost
      @order.apply_free_shipping_promotions

      packages = @order.shipments.map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      @differentiator.missing.each do |variant, quantity|
        @order.contents.remove(variant, quantity)
      end
      @order.state = "payment"
      @order.update_totals
      @order.persist_totals
      @order.ensure_line_item_variants_are_not_discontinued
      @order.ensure_line_items_are_in_stock
      @order.save!
    end

    def complete
      @order = Spree::Order.find(params[:id])

      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(china_pay_path) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
        else
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(china_pay_path) && return
        end
      else
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to(china_pay_path) && return
      end
    end


    private

    def provinces
    {
      "北京市": 'Beijing',
      "天津市": 'Tianjin',
      "河北省": 'Hebei',
      "山西省": 'Shanxi',
      "内蒙古自治区": 'Nei Mongol',
      "辽宁省": 'Liaoning',
      "吉林省": 'Jilin',
      "黑龙江省": 'Heilongjiang',
      "上海市": 'Shanghai',
      "江苏省": 'Jiangsu',
      "浙江省": 'Zhejiang',
      "安徽省": 'Anhui',
      "福建省": 'Fujian',
      "江西省": 'Jiangxi',
      "山东省": 'Shandong',
      "河南省": 'Henan',
      "湖北省": 'Hubei',
      "湖南省": 'Hunan',
      "广东省": 'Guangdong',
      "广西壮族自治区": 'Guangxi',
      "海南省": 'Hainan',
      "重庆市": 'Chongqing',
      "四川省": 'Sichuan',
      "贵州省": 'Guizhou',
      "云南省": 'Yunnan',
      "西藏自治区": 'Xizang',
      "陕西省": 'Shaanxi',
      "甘肃省": 'Gansu',
      "青海省": 'Qinghai',
      "宁夏回族自治区": 'Ningxia',
      "新疆维吾尔自治区": 'Xinjiang',
      "台湾省": 'Taiwan',
      "香港特别行政区": 'Xianggang (Hong-Kong)',
      "澳门特别行政区": 'Aomen (Macau)'
    }
    end

    def ensure_stripe_checkout
      if params[:stripeToken]
        stripe = PaymentMethod.find_by_type("Spree::Gateway::StripeGateway")
        unless params[:payment_source]
          params[:payment_source] = {}
        end
        params[:payment_source][stripe.id.to_s] = { :gateway_payment_profile_id => params[:stripeToken],
          :stripeTokenType => params[:stripeTokenType],
          :stripeEmail => params[:stripeEmail] }
        params.delete(:stripeToken)
        params.delete(:stripeTokenType)
        params.delete(:stripeEmail)
      end
    end

  end
end
