# frozen_string_literal: true

Rails.application.routes.draw do
  mount ApiDocs::Web => '/api-docs'
  get '/users/:id', to: 'application#show', as: 'show'
  get '/authenticate', to: 'application#authenticate', as: 'authenticate'
end
