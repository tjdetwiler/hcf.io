HcfIo::Application.routes.draw do
  resources :sessions
  resources :users

  get "projects/default"

  resources :projects do
    resources :files,
              :controller => "source_files",
              :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
  end

  get "home/index"
  root :to => "home#index"
  post "/login" => "sessions#login"
  get "/logout" => "sessions#logout"

end
