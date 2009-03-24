class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
  end
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    if params[:template_id]
      @tmpl = shop.templates.find(params[:template_id])
      @rendered_template = @tmpl.render(Order.new(@order, shop).to_liquid)
      render :text => @rendered_template
    else
      @tmpls = shop.templates
    end
  end
end