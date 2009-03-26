class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
  end
  
  def show
    respond_to do |format|
      format.js do
        if params[:template_id]
          @tmpl = shop.templates.find(params[:template_id])
          @rendered_template = "<h1>TOTO#{@tmpl.id}</h1>"#@tmpl.render(@order.to_liquid)
          @checked = params[:checked]
          #render :text => @rendered_template
        end
      end
      format.html do
        @order = ShopifyAPI::Order.find(params[:id])
        @tmpls = shop.templates
      end
    end
  end
end