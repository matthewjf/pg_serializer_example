Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :products, only: [:show, :index] do
      get 'fast_jsonapi', to: 'products#fast_jsonapi', on: :collection
      get 'pg_serializable', to: 'products#pg_serializable', on: :collection
      get 'jbuilder', to: 'products#jbuilder', on: :collection
    end
    resources :variations, only: [:show, :index]
  end
end
