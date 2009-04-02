class OrdersController < ApplicationController
  
  around_filter :shopify_session
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
  end
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    respond_to do |format|
      
      format.js do
        @tmpl = shop.templates.find(params[:template_id])
        @rendered_template = @tmpl.render(@order.to_liquid)

        render :update do |page|
          page.insert_html(:top, "preview-#{@tmpl.id}", :partial => "preview", :locals => {:rendered_template => @rendered_template, :tmpl => @tmpl})
        end
        
        puts @rendered_template
        puts @tmpl
        puts @order
      end
      
      format.html do
        @tmpls = shop.templates
      end
      
    end
  end
  
  def print
    
  end
end