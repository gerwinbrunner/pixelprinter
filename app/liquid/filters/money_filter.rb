module MoneyFilter
  def money(money)
    MoneyHelper.format(shop.money_format, money, shop.currency)
  end    

  def money_with_currency(money)
    MoneyHelper.format(shop.money_with_currency_format, money, shop.currency)
  end

  def money_no_decimals(money)
    MoneyHelper.format(shop.money_format, money, shop.currency, true)
  end    

  def money_without_currency(money)
    sprintf("%.2f", money.to_i/100.0)
  end    

  private
  
  def shop
    ShopifyAPI::Shop.cached
  end
end