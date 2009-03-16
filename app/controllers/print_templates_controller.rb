class Admin::PrintTemplatesController < AdminAreaController
  def index
    @tmpls = shop.print_templates
    respond_to do |format|
      format.js do
        # TODO: implement js index if needed, else delete
      end
      format.xml do
        render :xml => @tmpls
      end
    end
  end
  
  def show
    @tmpl = shop.print_templates.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js do
        if @tmpl
          render :partial => 'admin/assets/editor/template', :object => @tmpl
        else 
          render :update do |page|
            page.messenger.error "Template could not be found..."
          end
        end
      end
      format.xml do
        render :xml => @tmpl
      end
    end
  end

  def preview
    # TODO: dennis - create a bogus order in case the shop doesn't have any yet  
    @order = params[:order_id] ? shop.orders.find(params[:order_id]) : shop.orders.first
    
    @tmpl = shop.print_templates.find(params[:id])
    @rendered_template = @tmpl.render(@order.to_liquid)
    render :template => 'admin/print_templates/preview', :layout => false
  end
  
  def create
    @tmpl = shop.print_templates.new(params[:print_template])
    
    respond_to do |format|
      format.js do
        render :update do |page|
          if @tmpl.save
            page.messenger.notice "Successfully added printing template #{@tmpl.name}."
          else
            page.messenger.error "Error while trying to add a new printing template!"
          end
        end
      end
      format.xml do
        if @tmpl.save
          render :xml => @tmpl, :status => :created, :location => [:admin, @tmpl]
        else
          render :xml => @tmpl.errors, :status => :unprocessable_entity
        end
      end
    end
  end
  
  def update
    @tmpl = shop.print_templates.find(params[:id])
    success = @tmpl.update_attributes(params[:print_template])

    respond_to do |format|
      format.html do
        if success
          flash[:notice] = "Updated print template."
        else
          flash[:error] = "Error while trying to update print template: #{@tmpl.errors.full_messages.to_s}"
        end
        redirect_to [:admin, @tmpl]
      end
      format.js do
        begin
          render :update do |page|    
            page.messenger.notice "Successfully compiled and saved the template."        
            page.replace_html 'status-errorlist', ''
            page['status-log'].hide
            page['source'].remove_class_name 'compile-error'
            page['source'].add_class_name 'compile-ok'
          end
        rescue LiquidStorageBucket::StorageError, TemplateTableBucket::StorageError => e      
          render :update do |page|
            page.replace_html 'status-message', h("Syntax Error: #{e.message}")
            page.messenger.error "Error compiling the template."
            page['status-log'].show
            page['source'].add_class_name 'compile-error'
            page['source'].remove_class_name 'compile-ok'        
          end
        end 
      end
      format.xml do
        if success
          render :xml => @tmpl
        else
          render :xml => @tmpl.errors, :status => :unprocessable_entity
        end
      end
    end   
  end 
  
  def destroy
    @tmpl = shop.print_templates.find(params[:id])
    @tmpl.destroy
    respond_to do |format|
      format.js do
        page.messenger.notice "Deleted printing template #{@tmpl.name}..."
      end
      format.xml do
        head :ok
      end
    end
  end
  
  def batch_print
    # TODO: implement batch print
  end
end
