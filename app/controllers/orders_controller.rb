class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = shop.orders
  end
  
end