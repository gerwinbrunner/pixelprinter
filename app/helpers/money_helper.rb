module MoneyHelper
  
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


  def money(money)
    MoneyHelper.format(money_format, money, currency)
  end    

  def money_no_decimals(money)
    MoneyHelper.format(money_format, money, currency, true)
  end  
  
  def money_with_currency(money)
    MoneyHelper.format(money_with_currency_format, money, currency)
  end
  
  def money_with_currency_no_decimals(money)
    MoneyHelper.format(money_with_currency_format, money, currency, true)
  end
  
  def currency
    shop.currency    
  end    
  
  def money_prefix(with_currency = false)
    format_chunks(with_currency).first
  end
  
  def money_suffix(with_currency = false)
    format_chunks(with_currency).last
  end
  
  
  private

  def self.format_with_delimiters(cents, precision = 2, thousands = ',', decimal = '.')
    parts = sprintf("%.#{precision}f", cents / 100.0).split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{thousands}")
    parts.join(decimal)
  end
  
  
  def format_chunks(with_currency = false)
    chunks = (with_currency ? shop.money_with_currency_format : shop.money_format).split(/\{\{[^\{\}]*\}\}/)
    chunks[1] ||= ''
    chunks
  end
  
  def shop
    ShopifyAPI::Shop.current
  end
  
  def money_format
    shop.money_format.blank? ? "$ {{amount}}" : shop.money_format
  end
  
  def money_with_currency_format
    shop.money_with_currency_format.blank? ? "$ {{amount}} USD" : shop.money_with_currency_format
  end
end