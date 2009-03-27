require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  should_have_many :templates
  
  def setup
    @shop = Shop.create
  end
  
  should "add default templates when created" do
    # TODO: should be 3 templates when finished
    assert_equal 1, @shop.templates.count
  end
  
  should "be able to create an example order from an XML file" do
    order = @shop.example_order
  end
end
