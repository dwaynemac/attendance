Assistance::Application.routes.draw do

  devise_for :users 
  devise_scope :user do
    get "/login", :to => "devise/cas_sessions#new"
    get '/logout', to: "devise/cas_sessions#destroy"
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'attendances#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :time_slots do
    collection do
      get :vacancies
    end
  end
  resources :attendances
  resources :trial_lessons
  resources :contacts, :only => [:index, :show, :update]
  resources :stats, :only => [:index] do
    collection do
      get 'current_month', as: 'current_month', to: 'stats#index', easy_period: :current_month
      get 'last_month', as: 'last_month', to: 'stats#index', easy_period: :last_month
    end
  end

  namespace 'api' do
    namespace 'v0' do
      resources :contacts, only: [:show]
      resources :imports, only: [:create, :show] do
        member do
          get :failed_rows # GET /api/v0/imports/:id/failed_rows
        end
      end
    end
  end
  
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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
