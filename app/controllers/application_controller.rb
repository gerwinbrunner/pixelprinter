# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected
  
  def shop
    Shop.find_or_create_by_url(current_shop.url)
  end

  # Show 404 page with better error explanation when an Order or Template can't be found
  def rescue_action_in_public(exception)
    if exception.is_a?(ActiveResource::ResourceNotFound) || exception.is_a?(ActiveRecord::RecordNotFound)
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    else
      super
    end
  end
end
