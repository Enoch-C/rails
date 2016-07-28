module Spree
  class ChinaController < Spree::StoreController
    before_action :ensure_stripe_checkout, only: [:processpay]
    skip_before_filter  :verify_authenticity_token

    def index
      @promoter_email = params["p"]
    end

    def cart
      
    end

    def checkout
      unless params[:line_item][:sku]
        redirect_to :back
        return
      end
      if params[:line_item][:sku].empty?
        redirect_to :back
        return
      end
      @promoter_email = params["p"]
      @sku = params[:line_item][:sku]
      @num = params[:line_item][:quantity]
    end

    def pay
      unless params["mobile"] || params["name"] || params["province"] || params["city"] || params["street"]
        redirect_to :back
        return
      end
      if params["mobile"].empty? || params["name"].empty? || params["province"].empty? || params["city"].empty? || params["street"].empty?
        redirect_to :back
        return
      end
      @order = Spree::Order.new
      @order.generate_order_number
      @order.save!

      @order.promoter = Spree::Promoter.find_by_email(params["promoter_email"])

      phone = "86" + params["mobile"]

      begin
        user = Spree::User.create_with(password: "#{phone}@coolchoice.com3?~0vo").find_or_create_by("email": "#{phone}@coolchoice.com")
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      @order.associate_user!(user)

      quantities = params["num"].split(' ')
      params["sku"].split(' ').each_with_index {|sku, idx|
        variant = Spree::Variant.find_by_sku(sku)
        @line_item = @order.contents.add(
            variant,
            (quantities[idx] rescue nil) || 1,
            {}
        )
      }

      @order.next!

      name = params["name"]
      state = provinces[params["province"].to_sym]
      address = Spree::Address.new
      address.firstname = (name[1,name.size-1] == '' ? name[0] : name[1,name.size-1])
      address.lastname = name[0]
      address.address1 = params["street"]
      address.address2 = params["sub"] if params["sub"]
      address.phone = @order.user.email[0, @order.user.email.size - 15]
      address.city = params["city"]
      address.zipcode = "110000"
      address.state_id = Spree::State.find_by_name(state).id
      address.country_id = Spree::Country.find_by_name("China").id
      # unless address.same_as?(@order.bill_address)
      #   address.save
      #   @order.bill_address_id = address.id
      #   @order.ship_address_id = address.id
      # end
      # @order.update_line_item_prices!
      # @order.create_tax_charge!
      # @order.persist_user_address!
      params[:order] = {
        :bill_address_attributes=>{
          :firstname=>address.firstname,
          :lastname=>address.lastname,
          :address1=>address.address1,
          :address2=>address.address2,
          :city=>address.city,
          :phone=>address.phone,
          :zipcode=>address.zipcode,
          :state_id=>address.state_id,
          :country_id=>address.country_id
        },
        :ship_address_attributes=>{
          :firstname=>address.firstname,
          :lastname=>address.lastname,
          :address1=>address.address1,
          :address2=>address.address2,
          :city=>address.city,
          :phone=>address.phone,
          :zipcode=>address.zipcode,
          :state_id=>address.state_id,
          :country_id=>address.country_id
        }
      }
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        # packages = @order.shipments.map(&:to_package)
        # @differentiator = Spree::Stock::Differentiator.new(@order, packages)
        @order.next
      else
        invalid_resource!(@order)
      end
      @order.next
      @order.save!
    end

    def complete
      @order = Spree::Order.find(params["order_id"])
      unless @order.state == "complete"
        flash.now[:error] = @order.errors.full_messages.join("\n")+" => 该订单存在无法被处理，请重新下单。"
        render :index
        return
      end
    end

    def processpay
      @order = Spree::Order.find(params[:id])
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        if @order.completed? || @order.next
          puts "here paid!!! #{@order.state}"
          if @order.respond_to?(:"after_#{@order.state}", true)
            puts "after_#{@order.state}"
            @order.send(:"after_#{@order.state}")
          end
          @order.save!
          redirect_to :controller => 'china', :action => 'complete', :order_id => @order.id
        else
          flash.now[:error] = @order.errors.full_messages.join("\n")+" => 信用卡被拒绝，或支付宝无法完成扣款、余额不足"
          render :pay
        end
      else
        invalid_resource!(@order)
      end
    end

    private

    def mine_includes
      {
        order: {
          bill_address: {
            state: {},
            country: {},
          },
          ship_address: {
            state: {},
            country: {},
          },
          adjustments: {},
          payments: {
            order: {},
            payment_method: {},
          },
        },
        inventory_units: {
          line_item: {
            product: {},
            variant: {},
          },
          variant: {
            product: {},
            default_price: {},
            option_values: {
              option_type: {},
            },
          },
        },
      }
    end

    def invalid_resource!(resource)
      @resource = resource
      render "spree/api/errors/invalid_resource", status: 422
    end

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
