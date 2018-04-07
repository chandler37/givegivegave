Rails.application.routes.draw do
  devise_for :users, controllers:{ registrations: "registrations" }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  namespace :api do
    scope "v1", module: :v1 do # defaults: {format: :json} perhaps?
      resources :charities, except: [:new, :edit]
    end
  end
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
