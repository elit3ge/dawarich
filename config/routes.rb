# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'

  resources :settings, only: :index

  patch 'settings', to: 'settings#update'
  get 'settings/theme', to: 'settings#theme'
  post 'settings/generate_api_key', to: 'settings#generate_api_key', as: :generate_api_key

  resources :imports
  resources :exports, only: %i[index create destroy]
  resources :points, only: %i[index] do
    collection do
      delete :bulk_destroy
    end
  end
  resources :stats, only: :index do
    collection do
      post :update
    end
  end
  get 'stats/:year', to: 'stats#show', constraints: { year: /\d{4}/ }

  root to: 'home#index'
  devise_for :users

  get 'map', to: 'map#index'

  namespace :api do
    namespace :v1 do
      resources :points, only: :create # TODO: Deprecate in 1.0

      namespace :overland do
        resources :batches, only: :create
      end

      namespace :owntracks do
        resources :points, only: :create
      end
    end
  end
end
