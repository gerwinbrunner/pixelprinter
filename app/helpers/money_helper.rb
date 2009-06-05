module MoneyHelper
  
  def money(money, convert_from_cents = false)
    MoneyHelper.format(shop.money_format, money, shop.currency, convert_from_cents)
  end    

  def money_with_currency(money, convert_from_cents = false)
    MoneyHelper.format(shop.money_with_currency_format, money, shop.currency, convert_from_cents)
  end
  
  
  def self.format(args, amount, currency = nil, convert_from_cents = false)
    cents = amount.is_a?(String) ? amount.to_f : amount
    return '' unless cents
    
    cents = (cents * 100).to_i if convert_from_cents
    
    args.gsub(/\{\{\s*\w+\s*\}\}/) do |format|
      case format
      when /\bamount_no_decimals?\b/
        format_with_delimiters(cents, 0)
      when /\bamount_with_comma_separator\b/
        format_with_delimiters(cents, 2, '.', ',')
      when /\bcurrency\b/
        currency
      else
        format_with_delimiters(cents, 2)
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