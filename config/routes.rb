ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'

  map.resources :print_templates, :member => {:preview => :get}
  
  map.resources :orders, :only => [:index, :show]
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
