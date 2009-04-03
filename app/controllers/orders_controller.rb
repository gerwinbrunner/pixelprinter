class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
  end
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    @tmpls = shop.templates
  end
  
  def print
    
  end
end