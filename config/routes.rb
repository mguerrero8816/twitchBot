Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get :start_bot, to: 'home#start_bot'
  get :stop_bot, to: 'home#stop_bot'


end
