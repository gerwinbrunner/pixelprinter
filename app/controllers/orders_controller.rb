class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
    # TODO: make sure there is no error when all templates are deleted
    @default_template = @tmpls.find(:first, :conditions => {:default => true}) || @tmpls.find(:first)
  end
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    @tmpls = shop.templates
  end
  
  def print
    
  end
end