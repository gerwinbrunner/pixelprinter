ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'

  # this route is needed for Shopify's application links, because they append the id param with a question mark instead of rails nested style
  map.connect 'orders?id=:id', :controller => 'orders', :action => 'index'
  map.resources :orders, :only => [:index, :show], :member => {:preview => :get, :print => :post}
  map.resources :print_templates, :as => 'templates'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
