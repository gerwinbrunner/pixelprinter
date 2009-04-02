module OrderCalculations
  
  def tax_shipping?
    shop.tax_shipping?
  end
  
  def calculate_total_line_items_price
    line_items.to_ary.sum(0) { |i| i.price * i.quantity }
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
    shipping_line ? shipping_line.price : BigDecimal.new(0)
  end
  
  def shipping_title
    shipping_line ? shipping_line.title : ''
  end
  
  
  # added from the Order model
  def recalculate(options = {})
    self.total_line_items_price = calculate_total_line_items_price
    self.subtotal_price = calculate_subtotal_price
    self.total_price  = calculate_total_price
  end
  
  
  # TODO: probably get rid of all the discount stuff 
  def apply_discount(discount)
    # Block against discount being applied after an order has been authorized
    return if placed?
    
    unless applied_discount.nil?
      raise DiscountError, "Only a single discount can be applied to an order"
    end
    
    unless discount.requirements_met_by?(self)
      raise DiscountError, "The discount does not meet the requirements set by the shop for this order"
    end

    transaction do
      discount = AppliedDiscount.new(
        :order => self,
        :amount => discount.calculate_discount(self),
        :discount => discount,
        :code => discount.code
      )
      
      self.applied_discount = discount
      self.total_discounts = applied_discount.amount
      
      recalculate(:recalculate_taxes => true)
      save!
    end
  end
  
  def discount_amount
    applied_discount? ? applied_discount.amount : Money.empty
  end
  
  def discount_code
    applied_discount? ? applied_discount.code : ''
  end
  
  def applied_discount?
    applied_discount
  end
end