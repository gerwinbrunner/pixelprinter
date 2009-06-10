class LoginController < ApplicationController
  
  def index
    # don't ask user for his #{shop}.myshopify.com address if it is already provided
    redirect_to :controller => 'login', :action => "authenticate", :shop => params[:shop] if params[:shop].present?
  end


  def authenticate
    if params[:shop].blank?
      flash[:error] = "You entered a blank domain, please try again."
      redirect_to(:back)
    else
      redirect_to ShopifyAPI::Session.new(params[:shop]).create_permission_url
    end
  end

  # Shopify redirects the logged-in user back to this action along with
  # the authorization token t.
  # 
  # This token is later combined with the developer's shared secret to form
  # the password used to call API methods.
  def finalize
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t])
    if shopify_session.valid?
      session[:shopify] = shopify_session
      
      # save shop to local DB
      @shop = Shop.find_or_create_by_url(shopify_session.url)

      flash[:notice] = "Successfully logged into shopify store."
      redirect_to session.delete(:return_to) || '/orders'
    else
      flash[:error] = "Could not log into Shopify store."
      redirect_to :action => 'index'
    end
  end
  
  def logout
    session[:shopify] = nil
    flash[:notice] = "Successfully logged out."
    
    redirect_to :action => 'index'
  end
  
end 