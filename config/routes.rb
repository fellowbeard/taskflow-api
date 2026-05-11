Rails.application.routes.draw do
  post "/login", to: "sessions#create"
  get "/me", to: "sessions#show"
  delete "/logout", to: "sessions#destroy"

  resources :tasks, only: [:index, :show, :create, :destroy] do
    member do
      patch :assign
      patch :transition
    end
  end
end