Rails.application.routes.draw do
  devise_for :channels
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  resources :channel_bots do
    post   :add_moderator,              on: :member
    post   :add_command_permission,     on: :member
    delete :destroy_moderator,          on: :member
    delete :destroy_command_permission, on: :member
  end
  resources :custom_commands, except: [:new, :edit]
  resources :commands
  resources :moderators, except: [:new, :edit]
  resources :schedules
  resource :twitch_bots, only: [] do
    post :connect
    post :disconnect
  end
end
