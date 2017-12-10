Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  resource :twitch_bots, only: [] do
    post :connect
    post :disconnect
  end

  resources :schedules
  resources :custom_commands
  resources :channel_bots do
    post   :add_moderator,              on: :member
    post   :add_command_permission,     on: :member
    delete :destroy_moderator,          on: :member
    delete :destroy_command_permission, on: :member
  end
end
