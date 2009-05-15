require File.dirname(__FILE__) + '/../../test_helper'

class MoneyHelp
  extend MoneyHelper
end

class MoneyHelperTest < ActiveSupport::TestCase
  before do  
    ActiveResource::Base.site = 'http://any-url-for-testing'

    @european_shop = shop
    @us_shop = shop('shop.xml', {'money_format' => "${{amount}}", 'money_with_currency_format' => "${{amount}} USD", 'currency' => "USD"})
  end
  
  context "European shop" do
    before do
      ShopifyAPI::Shop.stubs(:current).returns(@european_shop)
    end
    
    should "render money for Fixnum value in Euros" do
      assert_equal "&euro;10.00", MoneyHelp.money(1000)
    end

    should "render money with currency for Fixnum values in Euros" do
      assert_equal "&euro;10.00 EUR", MoneyHelp.money_with_currency(1000)
    end

    should "render money for String value in Euros" do
      assert_equal "&euro;10.00", MoneyHelp.money("1000")
    end

    should "render money with currency for String values in Euros" do
      assert_equal "&euro;10.00 EUR", MoneyHelp.money_with_currency("1000")
    end

  end
  
  context "US Shop" do
    before do
      ShopifyAPI::Shop.stubs(:current).returns(@us_shop)
    end
    
    should "render money for fixnum values in $" do
      assert_equal "$10.00", MoneyHelp.money(1000)
    end

    should "render money with currency for fixnum values in $" do
      assert_equal "$10.00 USD", MoneyHelp.money_with_currency(1000)
    end
  end
end