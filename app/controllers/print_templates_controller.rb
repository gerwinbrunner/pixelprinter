class PrintTemplatesController < ApplicationController
  def new
    @tmpl = shop.templates.new
  end

  def preview
    # TODO: dennis - create a bogus order in case the shop doesn't have any yet  
    @order = params[:order_id] ? shop.orders.find(params[:order_id]) : shop.orders.first
    
    @tmpl = shop.templates.find(params[:id])
    @rendered_template = @tmpl.render(@order.to_liquid)
    render :template => 'preview', :layout => false
  end


  def batch_print
    # TODO: implement batch print
  end
  
  private
  
  def shop
    @shop = Shop.find_by_name(session[:shopify].name)
  end
end
