Rails.application.routes.draw do
  resources :tasks do
    member do
      patch :assign
      patch :transition
    end
  end
end