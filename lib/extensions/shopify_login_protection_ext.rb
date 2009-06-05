module ShopifyLoginProtection

  def shopify_session
    if params[:shop].present?
      session[:return_to] = request.path
      redirect_to :controller => 'login', :action => 'authenticate', :shop => params[:shop]
      yield
    elsif session[:shopify]
      begin
        # session[:shopify] set in LoginController#finalize
        ActiveResource::Base.site = session[:shopify].site
        ShopifyAPI::Shop.cached = session[:shopify].shop 
        yield
      ensure
        ActiveResource::Base.site = nil
        ShopifyAPI::Shop.cached = nil
      end
    else            
      session[:return_to] = request.path
      redirect_to :controller => 'login'
    end
  end
end