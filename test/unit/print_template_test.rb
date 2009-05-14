require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  def setup
    ActiveResource::Base.site = 'http://any-url-for-testing'
    @shop = Shop.create(:name => "My Shop")
  end

  should "not allow the same name for the same shop" do
    assert @shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert !@shop.templates.create(:name => "My name", :body => "something else").valid?
  end

  should "allow the same name for different shops" do
    assert @shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert Shop.create(:name => "My other Shop").templates.create(:name => "My name", :body => "something else").valid?
  end
  
  context "#from_file" do
    should "not create new record if saved already with same name" do
      template = @shop.templates.new
      assert template.new_record?
      # saving should fail, because other tests already created an instance in the DB (no duplicate names!)
      assert !template.load_from_file!(:invoice)
    end
    
    should "save body and name from that serialized template" do
      template = @shop.templates.new
      template.load_from_file!(:invoice)
      assert_equal 'invoice', template.name
      assert_equal File.read("#{RAILS_ROOT}/db/printing/invoice.liquid"), template.body
    end
  end
  
  
  context "#render" do
    setup do
      @template = @shop.templates.new
      @template.load_from_file!(:invoice)
      @order = ShopifyAPI::Order.example
      shop = stub(:name => "My Store", :currency => "USD", :money_format => "$ {{amount}}", :to_liquid => {})
      ShopifyAPI::Shop.stubs(:current).returns(shop)
    end
  end
end