require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  before do
    @shop = Shop.create
  end
  
  context "on_create" do
    should "add default templates when created" do
      assert_equal 3, @shop.templates.count
    end
    
    should "have invoice selected per default" do
      assert_equal true, @shop.templates.find_by_name('invoice').default
    end
  end
end
