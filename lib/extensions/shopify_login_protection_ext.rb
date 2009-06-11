module ShopifyLoginProtection

  def shopify_session
    if session[:shopify].blank? or shop_overwritten?
      original_request = "#{request.path}?#{request.query_string}"
      session[:return_to] = original_request
      redirect_to :controller => 'login', :action => 'index', :shop => params[:shop]
      return
    end

    ActiveResource::Base.site = session[:shopify].site
    logger.debug "Base site set to: '#{session[:shopify].site}'"
    ShopifyAPI::Shop.cached = session[:shopify].shop 
    yield
  ensure
    ActiveResource::Base.site = nil
    ShopifyAPI::Shop.cached = nil
  end
  
  
  private
  
  def shop_overwritten?
    return false if params[:shop].blank?

    params[:shop] != session[:shopify].url && "#{params[:shop]}.myshopify.com" != session[:shopify].url
  end
end