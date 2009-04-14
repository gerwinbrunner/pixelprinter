require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  should_belong_to :shop
  should_validate_presence_of :body
  should_ensure_length_in_range :name, 2..32
  should_not_allow_mass_assignment_of :shop_id

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
      shop = stub(:name => "My Store", :currency => "USD", :money_format => "$ {{amount}}")
      ShopifyAPI::Shop.stubs(:current).returns(shop)
    end
    
    should "successfully insert all used variables from template" do
      assert_render_liquid(@template, @order.to_liquid)
    end
    
    should "successfully render all variables available from order" do
      @template.load_from_file!('../../test/fixtures/example_print_template')
      assert_render_liquid(@template, @order.to_liquid)
    end 
  end
end