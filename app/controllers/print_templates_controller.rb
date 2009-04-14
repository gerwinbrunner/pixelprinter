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
    @tmpl = shop.templates.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml do
        render :xml => @tmpl
      end
    end
  end
  
  def new
    @tmpls = shop.templates
    @tmpl = @tmpls.new
    if params[:id]
      original = shop.templates.find(params[:id])
      @tmpl.name = original.name + "--COPY"
      @tmpl.body = original.body
    end
    render :template => 'print_templates/new', :layout => false
  end

  def create
    @tmpl = shop.templates.build(params[:print_template])
    if @tmpl.save
      msg = "Successfully added printing template #{@tmpl.name}."
    else
      msg = "Error while trying to add a new printing template!"
      render :update do |page|
        errs = @tmpl.errors.full_messages.to_sentence
        page.alert(errs)
      end
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
      msg = "Error while trying to update print template: #{@tmpl.errors.full_messages.to_s}"
      render :update do |page|
        errs = @tmpl.errors.full_messages.to_sentence
        page.alert(errs)
      end        
    end
  end 

  def destroy
    @tmpl = shop.templates.find(params[:id])
    @tmpl.destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'index'
      end
      format.xml do
        head :ok
      end
    end
  end

  def preview
    @tmpl  = params[:id] ? shop.templates.find(params[:id]) : shop.templates.new(params[:print_template])
    @order = params[:order_id].blank? ? ShopifyAPI::Order.example : ShopifyAPI::Order.find(params[:order_id])
    @rendered_template = @tmpl.render(@order.to_liquid)

    render :partial => "preview", :locals => {:rendered_template => @rendered_template, :tmpl => @tmpl}
  end
  
end
