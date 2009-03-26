module OrderCalculations
  
  def tax_shipping?
    shop.tax_shipping?
  end
  
  def calculate_total_line_items_price
    line_items.to_ary.sum(Money.empty) { |i| i.price * i.quantity }
  end
  
  def calculate_subtotal_price
    total_line_items_price - total_discounts
  end
  
  def calculate_total_price        
    sum  = shipping_price + subtotal_price
    
    sum += total_tax unless taxes_included?
    sum
  end
    
  def calculate_total_tax
    calculator = TaxCalculator.new(shipping_address || location || {})
    calculator.calculate_tax_on(tax_shipping? ? subtotal_price + shipping_price : subtotal_price,
      :tax_included_in_price => taxes_included?
    ).total
  end
  
  def shipping_price
    shipping_line ? shipping_line.price : Money.empty
  end
  
  def shipping_title
    shipping_line ? shipping_line.title : ''
  end
  
end