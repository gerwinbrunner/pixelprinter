require File.dirname(__FILE__) + '/../test_helper'

class OrdersControllerTest < ActionController::TestCase
  tests OrdersController
 
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'
    ShopifyAPI::Shop.stubs(:current).returns(shop)
    
    @session = login_session(:germanbrownies)
  end
  
  context "show" do
    should "display templates in sidebar ordered by newest template at the bottom" do
      ShopifyAPI::Order.expects(:find).with('1').returns(order)
      get :show, {:id => 1}, @session
      assert_response :ok

      templates = assigns(:tmpls)
      assert_equal 3, templates.size
      p templates.collect(&:id)
      assert_equal "Invoice", templates.first.name
    end
  end
  
end