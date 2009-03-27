ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'
  
  map.resources :print_templates
  map.resources :orders, :only => [:index, :show], :member => {:print => :get}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
