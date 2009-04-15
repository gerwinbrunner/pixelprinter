ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'

  map.resources :orders, :only => [:index, :show]
  map.resources :print_templates, :collection => {:preview => :get}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
