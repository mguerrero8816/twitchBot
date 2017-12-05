Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  resource :twitch_bots, only: [] do
    post :connect
    post :disconnect
  end

  resources :schedules

end
