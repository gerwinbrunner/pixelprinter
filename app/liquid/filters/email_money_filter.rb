module EmailMoneyFilter
    
  def money(money)                 
    return money if ShopifyAPI::Shop.current.nil?
    MoneyHelper.format(MoneyHelper.money_in_emails_format, money, ShopifyAPI::Shop.current.currency)
  end

  def money_with_currency(money)
    return money if ShopifyAPI::Shop.current.nil?
    MoneyHelper.format(MoneyHelper.money_with_currency_in_emails_format, money, ShopifyAPI::Shop.current.currency)
  end
  
end