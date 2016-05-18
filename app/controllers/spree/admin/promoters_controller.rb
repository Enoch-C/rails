module Spree
  module Admin
    class PromotersController < ResourceController
      # http://spreecommerce.com/blog/2010/11/02/json-hijacking-vulnerability/
      before_action :check_json_authenticity, only: :index

      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
      end

      def show
        redirect_to edit_admin_promoter_path(@promoter)
      end

      def create
        @promoter = Spree::Promoter.new(promoter_params)
        if @promoter.save
          flash.now[:success] = flash_message_for(@promoter, :successfully_created)
          render :edit
        else
          render :new
        end
      end

      def update
        if @promoter.update_attributes(promoter_params)
          flash.now[:success] = Spree.t(:account_updated)
        end

        render :edit
      end

      def orders
        params[:q] ||= {}
        @search = Spree::Order.reverse_chronological.ransack(params[:q].merge(promoter_id_eq: @promoter.id))
        @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def items
        params[:q] ||= {}
        @search = Spree::Order.includes(
          line_items: {
            variant: [:product, { option_values: :option_type }]
          }).ransack(params[:q].merge(promoter_id_eq: @promoter.id))
        @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def users
        params[:q] ||= {}
        @search = Spree::User.ransack(params[:q].merge(promoter_id_eq: @promoter.id))
        @users = @search.result.page(params[:page]).per(20)
      end

      def model_class
        Spree::Promoter
      end

      protected

        def collection
          return @collection if @collection.present?
          @collection = super
          if request.xhr? && params[:q].present?
            @collection = @collection.includes(:bill_address, :ship_address)
                              .where("promoters.email #{LIKE} :search
                                     OR (spree_addresses.firstname #{LIKE} :search AND spree_addresses.id = spree_users.bill_address_id)
                                     OR (spree_addresses.lastname  #{LIKE} :search AND spree_addresses.id = spree_users.bill_address_id)
                                     OR (spree_addresses.firstname #{LIKE} :search AND spree_addresses.id = spree_users.ship_address_id)
                                     OR (spree_addresses.lastname  #{LIKE} :search AND spree_addresses.id = spree_users.ship_address_id)",
                                    { :search => "#{params[:q].strip}%" })
                              .limit(params[:limit] || 100)
          else
            @search = @collection.ransack(params[:q])
            @collection = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
          end
        end

      private

      def promoter_params
        params.require(:promoter).permit(:phone, :secret, :email, :first_name, :last_name, :percent)
      end

      # Allow different formats of json data to suit different ajax calls
      def json_data
        json_format = params[:json_format] || 'default'
        case json_format
        when 'basic'
          collection.map { |u| { 'id' => u.id, 'name' => u.email } }.to_json
        else
          address_fields = [:firstname, :lastname, :address1, :address2, :city, :zipcode, :phone, :state_name, :state_id, :country_id]
          includes = { only: address_fields, include: { state: { only: :name }, country: { only: :name } } }

          collection.to_json(only: [:id, :email], include:
                             { bill_address: includes, ship_address: includes })
        end
      end

    end
  end
end
