module MoneyFilter
  def money_with_currency(money)
    MoneyHelper.format ShopifyAPI::Shop.current.money_with_currency_format, money, ShopifyAPI::Shop.current.currency
  end

  def money(money)
    MoneyHelper.format ShopifyAPI::Shop.current.money_format, money, ShopifyAPI::Shop.current.currency
  end                  
  
  def money(money)
    MoneyHelper.format ShopifyAPI::Shop.current.money_format, money, ShopifyAPI::Shop.current.currency
  end    

  def money_no_decimals(money)
    MoneyHelper.format ShopifyAPI::Shop.current.money_format, money, ShopifyAPI::Shop.current.currency, true
  end    

  def money_without_currency(money)
    sprintf("%.2f", money.to_i/100.0)
  end    
  
end