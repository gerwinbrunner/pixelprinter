require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  should_belong_to :shop
  should_validate_presence_of :body
  should_ensure_length_in_range :name, 2..32
  should_not_allow_mass_assignment_of :shop_id
  
  def setup
    ActiveResource::Base.site = 'http://any-url-for-testing'
    @shop = Shop.create(:name => "My Shop")
    @template = @shop.templates.new
    @template.from_file(:invoice)
  end
  
  context "#load_template" do
    should "save body and name from that template" do
      assert !@template.new_record?
      assert_equal 'invoice', @template.name
      assert_equal File.read("#{RAILS_ROOT}/db/printing/invoice.liquid"), @template.body
    end
  end
  
  
  context "#render" do
    setup do
      @order = ShopifyAPI::Order.example
      shop = stub(:name => "My Store", :currency => "USD", :money_format => "$ {{amount}}")
      ShopifyAPI::Shop.stubs(:current).returns(shop)
    end
    
    should "successfully insert all used variables from template" do
      assert_render_liquid(@template, @order.to_liquid)
    end
    
    should "successfully render all variables available from order" do
      @template.from_file('../../test/fixtures/example_print_template')
      assert_render_liquid(@template, @order.to_liquid)
    end
    
  end
end