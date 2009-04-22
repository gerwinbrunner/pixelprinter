require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  should_have_many :templates
  
  def setup
    @shop = Shop.create
  end
  
  should "add default templates when created" do
    # TODO: should be 3 templates when finished
    assert_equal 2, @shop.templates.count
  end
end
