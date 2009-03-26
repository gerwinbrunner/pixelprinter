require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  should_have_many :templates
  
  should "add default templates when created" do
    shop = Shop.create

    # TODO: should be 3 templates when finished
    assert_equal 1, shop.templates.count
  end
end
