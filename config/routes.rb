BeautyBookMillennium::Application.routes.draw do

  resources :employees


  authenticated :user do
    root :to => "search#index"
  end
  root :to => "search#index"
  devise_for :users, path_prefix: 'd'
  devise_scope :user do
    get "d/users/sign_in" => "users/sessions#new",      :as => :new_user_session
    get "d/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end
  resources :users, except: [:index, :edit, :update, :show, :destroy]

  resources :services


  
  
  resources :search, only: [:index] do
    collection do
      post :slots
    end
  end

  resources :appointments do
    collection do
      post :book_appointment
      get :check_price
    end
    #      member do
    #        post :confirm_appointment
    #        post :cancel_appointment
    #        post :home_search
    #      end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
