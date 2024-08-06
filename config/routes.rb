Rails.application.routes.draw do
  devise_for :admins
  devise_for :users
  resources :categories

  resources :products do
    resource :buy_now, only: [:show, :create], controller: :buy_now do
      get "success", on: :collection
    end
  end

  resource :cart, only: [:show, :destroy, :create] do
    get "checkout", on: :collection, to: "carts#checkout"
    post "stripe_session", on: :member, to: "carts#stripe_session"
    get "success", on: :member, to: "carts#success"
  end

  resources :orders, only: [:index, :show]

  resource :admin, only: [:show], controller: :admin

  root "products#index"
end
