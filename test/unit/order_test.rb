require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    ActiveResource::Base.site = 'http://any-url-for-testing'
  end
  
  should "respond to #to_liquid" do
    @order = ShopifyAPI::Order.new
    assert_respond_to(@order, :to_liquid)
  end
  
  context "generating an example order" do
    setup do
      @order = order
    end
    
    should "be an instance of ShopifyAPI::Order" do
      assert_instance_of(ShopifyAPI::Order, @order)
    end
  
    should "have an address of type ShopifyAPI::Address" do
      assert_kind_of(ShopifyAPI::Address, @order.shipping_address)
    end
    
    should "have at least one line item" do
      assert @order.line_items.size > 0
      assert_instance_of(ShopifyAPI::LineItem, @order.line_items.first)
    end
  end
  
  context "#to_liquid" do
    setup do
      @order = order
      shop = stub(:name => "My Store", :currency => "USD", :money_format => "$ {{amount}}", :to_liquid => {'name' => "My Store"})
      ShopifyAPI::Shop.stubs(:current).returns(shop)
      @liquid = @order.to_liquid
    end
    
    should "return the current shop with shop_name" do
      assert_equal "My Store", @liquid['shop_name']
    end

    should "return the current shop with shop.name" do
      assert_equal "My Store", @liquid['shop']['name']
    end
    
    should "return total price as cents" do
      assert_equal '1960', @liquid['total_price'].to_s
    end
    
    should "return line item name" do
      assert_equal "Shopify T-Shirt", @liquid['line_items'].first.name
    end
    
    should "return customer email with customer.email" do
      assert_equal 'johnsmith@shopify.com', @liquid['customer']['email']
    end
    
  end
end
