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
    # Not used at the moment (see orders/show)
    @tmpl  = shop.templates.find(params[:id])
    @order = ShopifyAPI::Order.find(params[:order_id])
  end

  
  def new
    @tmpl = shop.templates.new
    if params[:id]
      original = shop.templates.find(params[:id])
      @tmpl.name = original.name + "--COPY"
      @tmpl.body = original.body
    end
    # render RJS template
  end

  def create
    @tmpl = shop.templates.build(params[:print_template])
    if @tmpl.save
      # render RJS template
    else
      render :js => "Messenger.error(\"#{@tmpl.errors.full_messages.to_sentence}.\");"
    end
  end


  def edit
    @tmpls = shop.templates
    @tmpl = @tmpls.find(params[:id])
    # render RJS template
  end
  
  def update
    @tmpl = shop.templates.find(params[:id])
    
    if @tmpl.update_attributes(params[:print_template])
      # render RJS template
    else
      render :js => "Messenger.error(\"#{@tmpl.errors.full_messages.to_sentence}.\");"
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
        # render RJS template
      end
      format.xml do
        head :ok
      end
    end
  end
  
  def fetch_versions
    @tmpl = shop.templates.find_by_name(params[:template_name])
    
    respond_to do |format|
      format.js
    end
  end
  
  def rollback_template
    @tmpl = shop.templates.find_by_name(params[:template_name])
    @tmpl.rollback(params[:template_version]) if params[:template_version].present?
    
    render :update do |page|
      page << "$('#template_editor').val(#{@tmpl.body.inspect});"
    end
  end
end
