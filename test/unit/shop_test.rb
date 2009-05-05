require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase
  should_have_many :templates
  
  def setup
    @shop = Shop.create
  end
  
  should "add default templates when created" do
    assert_equal 3, @shop.templates.count
  end
end
