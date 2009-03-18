class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all, :params => {:order => "created_at DESC" })
  end
  
end