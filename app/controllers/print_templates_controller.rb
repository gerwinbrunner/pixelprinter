class PrintTemplatesController < ApplicationController
  around_filter :shopify_session
  
  def index
    @tmpls = shop.templates
    respond_to do |format|
      format.html
      format.xml do
        render :xml => @tmpls
      end
    end
  end
  
  def show
    @tmpl  = shop.templates.find(params[:id])
    @order = params[:order_id].blank? ? ShopifyAPI::Order.example : ShopifyAPI::Order.find(params[:order_id])
  end

  
  def new
    @tmpl = shop.templates.new
    if params[:id]
      original = shop.templates.find(params[:id])
      @tmpl.name = original.name + "--COPY"
      @tmpl.body = original.body
    end
  end

  def create
    @tmpl = shop.templates.build(params[:print_template])
    if @tmpl.save
      msg = "Successfully added printing template #{@tmpl.name}."
    else
      msg = @tmpl.errors.full_messages.to_sentence
      render :js => "Status.error('#{msg}.')"
    end
  end


  def edit
    @tmpls = shop.templates
    @tmpl = @tmpls.find(params[:id])
    render :template => 'print_templates/edit', :layout => false
  end
  
  def update
    @tmpl = shop.templates.find(params[:id])
    
    if @tmpl.update_attributes(params[:print_template])
      msg = "Updated print template."
    else
      msg = @tmpl.errors.full_messages.to_sentence
      render :js => "Status.error('#{msg}.')"
    end
  end 


  def destroy
    @tmpl = shop.templates.find(params[:id])
    @tmpl.destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'index'
      end
      format.js do
        render :js => "Status.notify('Deleted template #{@tmpl.name}.')"
      end
      format.xml do
        head :ok
      end
    end
  end
end
