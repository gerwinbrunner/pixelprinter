ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'

  map.resources :orders, :only => [:index, :show], :member => {:preview => :get, :print => :post}
  map.resources :print_templates, :as => 'templates'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
