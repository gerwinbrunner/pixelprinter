# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def shopify_order_url(order)
    "#{ShopifyAPI::Session.protocol}://#{session[:shopify].url}/admin/orders/#{order.id}"
  end
end
