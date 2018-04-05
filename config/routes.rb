Rails.application.routes.draw do
  devise_for :users, controllers:{ registrations: "registrations" }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :charities
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
