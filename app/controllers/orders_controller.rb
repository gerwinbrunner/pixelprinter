class OrdersController < ApplicationController
  protect_from_forgery :except => 'print'
  
  around_filter :shopify_session

  # caches_action :preview, :cache_path => Proc.new { |controller| "orders/#{controller.params[:id]}?template_id=#{controller.params[:template_id]}" }
  #
  # Caching like this works, but it has 2 big problems:
  #   1. The shop must be included in the cache key too
  #   2. How to expire if a template changes (e.g. order id is not available in PrintTemplatesController) or worse an Order changes in Shopify
  
  def index
    @orders = ShopifyAPI::Order.find(:all)
    @tmpls  = shop.templates
    # TODO: make sure there is no error when all templates are deleted
    @default_template = @tmpls.find(:first, :conditions => {:default => true}) || @tmpls.find(:first)
  end
  
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    @tmpls = shop.templates
    
    respond_to do |format|
      format.html
      format.js do
        # AJAX preview, loads in modal Dialog
        @tmpl = shop.templates.find(params[:template_id])
      end
    end
  end

  # return the raw rendered HTML content to refer to from an IFrame
  def preview
    @tmpl  = shop.templates.find(params[:template_id])
    @order = ShopifyAPI::Order.find(params[:id])
    @rendered_template = @tmpl.render(@order.to_liquid)

    render :text => @rendered_template
  end

  def print
    @all_templates = shop.templates
    @printed_templates = @all_templates.find(params[:print_templates])
    
    @all_templates.each { |tmpl| tmpl.update_attribute(:default, @printed_templates.include?(tmpl)) }
    head 200
  end
end