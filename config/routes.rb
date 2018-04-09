Rails.application.routes.draw do
  devise_for :users, controllers:{ registrations: "registrations" }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  namespace :api do
    scope "v1", module: :v1 do # defaults: {format: :json} perhaps?
      resources :causes, only: [:index, :show, :create, :update, :destroy]
      resources :charities, except: [:new, :edit] do
        # :index is not needed because you can show a charity to see its
        # causes. This does not create a cause, though; this merely associates
        # an existing cause with the charity:
        resources :causes, only: [:create, :destroy]
      end
    end
  end
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
