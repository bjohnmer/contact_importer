Rails.application.routes.draw do
  default_url_options :host => ENV['RAILS_DEFAULT_URL']

  root to: "contacts#index"
  resources :contacts, only: [:index]
  namespace :imported_files do
   get 'index'
   get 'upload'
   post 'import'
  end

  get 'imported_files/:id', to: 'imported_files#show', as: :imported_files_show

  devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout' }
end
