module OrderHelper
  def order_status(order)
    content_tag :span, order.financial_status, :class => "o-status o-#{order.financial_status}"
  end
end