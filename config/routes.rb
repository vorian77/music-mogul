Mvp2::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get '/account' => 'users#edit', :as => :account
  put '/account' => 'users#update'
  post '/account/profile_video' => 'users#create_profile_video', :as => :account_profile_video
  get '/account/thumbnail' => 'users#edit_thumbnail', :as => :edit_thumbnail
  put '/account/thumbnail' => 'users#update_thumbnail', :as => :update_thumbnail

  match 'video' => 'home#video', :as => :home_video
 
  get '/upload' => 'users#upload', :as => :upload
  get '/s3_callback' => 'users#s3_callback', :as => :s3_callback

	root :to => 'home#index'
	
  # get '/Fans' => 'home#fans', :as => :home_fans
	
	get '/page/:name' => 'pages#show', :as => :page

end
