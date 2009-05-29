module MoneyHelper
  
  def money(money)
    MoneyHelper.format(shop.money_format, money, shop.currency)
  end    

  def money_with_currency(money)
    MoneyHelper.format(shop.money_with_currency_format, money, shop.currency)
  end
  
  
  def self.format(args, amount, currency = nil, strip_precision = false)    
    cents = case amount
    when Money then amount.cents
    when NilClass, nil then return ''
    when Numeric then amount
    when String then amount.to_i
    end                          
    precision = 2

    if strip_precision
      precision = 0
      cents = (cents / 100.0).floor * 100
    end


    args.gsub(/\{\{\s*\w+\s*\}\}/) do |format|
      case format
      when /\bamount_no_decimals?\b/
        format_with_delimiters(cents, 0)
      when /\bamount_with_comma_separator\b/
        format_with_delimiters(cents, precision, '.', ',')
      when /\bcurrency\b/
        currency
      else
        format_with_delimiters(cents, precision)
      end
    end    
  end
   
  
  private

  def self.format_with_delimiters(cents, precision = 2, thousands = ',', decimal = '.')
    parts = sprintf("%.#{precision}f", cents / 100.0).split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{thousands}")
    parts.join(decimal)
  end
  
  def shop
    ShopifyAPI::Shop.cached
  end
  
end