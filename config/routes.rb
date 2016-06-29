Rails.application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'
          # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Spree::Core::Engine.add_routes do
  get '/why', to: 'why#index'
  get '/gift', to: 'gift#index'
  get '/gift/my_gift', to: 'gift#my_gift'
  get '/gift/my_address', to: 'gift#my_gift_shipping_address'
  get '/gift/my_gift_completion', to: 'gift#my_gift_completion'
  post '/index/wish', to: 'home#wish'

  get '/ingredient', to: 'ingredient#index'

  get 'localization', to: 'localization#index'

  get 'faq', to: 'faq#index'
  get 'T&C', to: 'terms#index'

  namespace :admin, path: Spree.admin_path do
    resources :promoters do
      member do
        # get :addresses
        # put :addresses
        # put :clear_api_key
        # put :generate_api_key
        get :items
        get :orders
        get :users
      end
      # resources :store_credits
    end

    resources :orders do
      member do
        get :labels
      end
    end
  end
end
