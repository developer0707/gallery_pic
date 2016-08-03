Rails.application.routes.draw do

  root to: "get/get#show"

  get 'counters/users'

  get 'counters/posts'

  get 'counters/comments'

  namespace :api do
    get 'photos' => 'photos#show'
  end

  get 'imports/upload'
  post 'imports/upload'

  get 'imports' => 'imports#all'
  get 'imports/categories' => 'imports#categories'
  get 'imports/countries' => 'imports#countries'
  get 'imports/states' => 'imports#states'
  get 'imports/cities' => 'imports#cities'
  get 'imports/places' => 'imports#places'
  get 'imports/users' => 'imports#users'
  get 'imports/installations' => 'imports#installations'
  get 'imports/posts' => 'imports#posts'
  get 'imports/comments' => 'imports#comments'
  get 'imports/rounds' => 'imports#rounds'
  get 'imports/actions' => 'imports#actions'
  get 'imports/text_mentions' => 'imports#text_mentions'

  post 'imports/parse_insert_object'
  get 'imports/parse_insert_object'

  post 'imports/parse_delete_object'
  get 'imports/parse_delete_object'

  #Installation

  post 'installations' => 'installations#create'

  put 'installations/:id' => 'installations#update'

  #Session

  post 'login' => 'sessions#create'

  delete 'logout' => 'sessions#destroy'

  delete 'signout' => 'sessions#destroy'

  #Posts

  get 'categories/posts/search' => 'posts#categories_search'

  get 'feed' => 'posts#index'

  get 'explore' => 'posts#explore'

  get 'categories/:category_id/posts' => 'posts#category_posts'

  get 'places/:place_id/posts' => 'posts#place_posts'

  get ':user_id/posts' => 'posts#user_posts'

  get 'users/:user_id/posts' => 'posts#user_posts'

  post 'posts' => 'posts#create'

  get 'posts/:id' => 'posts#show'

  delete 'posts/:id' => 'posts#destroy'

  put 'posts/:id/like' => 'posts#like'

  put 'posts/:id/report' => 'posts#report'

  put 'posts/:id/vote' => 'posts#vote'

  #Comments

  delete 'comments/:id' => 'comments#destroy'

  put 'comments/:id/like' => 'comments#like'

  put 'comments/:id/report' => 'comments#report'

  post 'comments' => 'comments#create'

  get 'posts/:post_id/comments' => 'comments#index'

  #Categories

  get 'categories' => 'categories#index'

  #Actions/Notifications

  get 'notifications' => 'activities#index'

  #Places

  get 'places' => 'places#index'

  get 'places/search' => 'places#search'

  #Media

  post 'media' => 'media_files#create'

  post 'media/create' => 'media_files#create'

  get 'media/:id' => 'media_files#show', as: 'media_files'

  #rounds

  get 'rounds' => 'rounds#index'

  get 'rounds/:id' => 'rounds#show'
  
  #User

  get 'users/search'

  get 'users/:id' => 'users#show'

  post 'users' => 'users#create'

  put 'users/:id/follow' => 'users#follow'

  put 'users/:id/report' => 'users#report'

  put 'users/:id/block' => 'users#block'

  put 'users/:id' => 'users#update'

  get 'users/:id/followers' => 'users#followers'

  get 'users/:id/follows' => 'users#follows'

  get 'posts/:post_id/likes' => 'posts#likes'

  get 'comments/:comment_id/likes' => 'comments#likes'

  put 'users/:id/update_email' => 'users#update_email'

  get 'change_password' => 'users#change_password'
  post 'change_password' => 'users#change_password'

  post 'reset_password' => 'users#reset_password'

  #Countries, states and cities

  get 'countries' => 'countries#index'

  get 'countries/:country_id/states' => 'states#index'

  get 'states/:state_id/cities' => 'cities#index'

  #Referral Codes

  post 'invitations' => 'referral_codes#create'

  namespace :admin do
    get 'rounds' => 'rounds#index'
    
    post 'rounds' => 'rounds#create'
 
    delete 'rounds/:id'  => 'rounds#destroy', as: 'destroy_round'

    get 'rounds/new', as: 'new_round'
  
    get 'rounds/:id/posts' => 'posts#round_posts', as: 'round_posts'

    post 'rounds/:id/posts' => 'posts#update_round_posts'

    get 'rounds/:id/posts/:post_id/votes' => 'posts#votes'
    
    post 'rounds/:id/posts/:post_id/votes' => 'posts#votes'
  end

  namespace :get do
    root to: 'get#show'
  end

end
