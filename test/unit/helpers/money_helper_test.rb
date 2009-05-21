require File.dirname(__FILE__) + '/../../test_helper'

class MoneyHelperTest < ActiveSupport::TestCase
  before do  
    ActiveResource::Base.site = 'http://any-url-for-testing'
    @european_shop = shop('shop.xml', {'money_format' => "&euro;{{amount}}", 'money_with_currency_format' => "&euro;{{amount}} EUR"})
    @us_shop       = shop('shop.xml', {'money_format' => "${{amount}}", 'money_with_currency_format' => "${{amount}} USD", 'currency' => "USD"})
    @filter = Object.new.extend(MoneyFilter)
  end
  

  should "cache the shop in MoneyFilter and not fetch the shop twice via ActiveResource" do
    ShopifyAPI::Shop.expects(:current).once.returns(@european_shop)
    @filter.money(1000)
  end
  
  should "invalidate the cached shop in MoneyFilter when a money filter is called " do
    # get Shop once in order#to_liquid and once in MoneyHelper#shop
    ShopifyAPI::Shop.expects(:current).once.returns(@us_shop)
    assert_equal "$10.00", @filter.money(1000)
    
    ShopifyAPI::Shop.expects(:current).once.returns(@european_shop)
    # simulate a new liquid render action by including the filter again in a new object
    # this will reset the instance variables (i.e. the cached remote shop)
    @filter = Object.new.extend(MoneyFilter)
    assert_equal "&euro;10.00", @filter.money(1000)
  end

  
  context "European shop" do
    before do
      ShopifyAPI::Shop.stubs(:current).returns(@european_shop)
    end

    should "render money for Fixnum value in Euros" do
      assert_equal "&euro;10.00", @filter.money(1000)
    end

    should "render money with currency for Fixnum values in Euros" do
      assert_equal "&euro;10.00 EUR", @filter.money_with_currency(1000)
    end

    should "render money for String value in Euros" do
      assert_equal "&euro;10.00", @filter.money("1000")
    end

    should "render money with currency for String values in Euros" do
      assert_equal "&euro;10.00 EUR", @filter.money_with_currency("1000")
    end
  end
  
  context "US Shop" do
    before do
      ShopifyAPI::Shop.stubs(:current).returns(@us_shop)
    end
    
    should "render money for fixnum values in $" do
      assert_equal "$10.00", @filter.money(1000)
    end

    should "render money with currency for fixnum values in $" do
      assert_equal "$10.00 USD", @filter.money_with_currency(1000)
    end
  end
end