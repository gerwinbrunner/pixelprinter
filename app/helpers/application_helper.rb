# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def shop_admin_url(sub_page = nil)
    sub_page = "/#{sub_page}" if sub_page
    "https://#{current_shop.url}/admin#{sub_page}"
  end
  
  def shopify_order_url(order)
    "#{shop_admin_url}/orders/#{order.id}"
  end
end
