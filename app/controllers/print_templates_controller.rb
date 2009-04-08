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
    @tmpl = shop.templates.new
    if params[:id]
      original = shop.templates.find(params[:id])
      @tmpl.name = original.name + "--COPY"
      @tmpl.body = original.body
    end
  end

  def create
    @tmpl = shop.templates.build(params[:print_template])
    respond_to do |format|
      if @tmpl.save
        format.html do
          flash[:notice] = "Successfully added printing template #{@tmpl.name}."
          redirect_to @tmpl
        end
        format.xml do
          render :xml => @tmpl, :status => :created, :location => [:admin, @tmpl]
        end
      else
        format.html do
          flash[:error] = "Error while trying to add a new printing template!"
          render :action => 'new'
        end
        format.xml do
          render :xml => @tmpl.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  def edit
    @tmpl = shop.templates.find(params[:id])
  end
  
  def update
    @tmpl = shop.templates.find(params[:id])

    respond_to do |format|
      if @tmpl.update_attributes(params[:print_template])
        format.html do
          flash[:notice] = "Updated print template."
          redirect_to @tmpl
        end
        format.xml do
          render :xml => @tmpl
        end 
      else
        format.html do
          flash[:error] = "Error while trying to update print template: #{@tmpl.errors.full_messages.to_s}"
          render :action => 'new'
        end
        format.xml do
          render :xml => @tmpl.errors, :status => :unprocessable_entity
        end
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
