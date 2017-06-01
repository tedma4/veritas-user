Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :update, :index]
  get "search", to: "users#search"
  resources :sessions, only: [:create, :delete]
  match '/sessions' => 'sessions#create', via: :post
  match '/sessions' => 'sessions#destroy', via: :delete
end
