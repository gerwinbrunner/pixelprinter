require File.dirname(__FILE__) + '/../test_helper'

class OrdersControllerTest < ActionController::TestCase
  tests OrdersController
 
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'

    @invoice = print_templates(:invoice)
    @js_template = print_templates(:javascript_content)
    
    ShopifyAPI::Shop.stubs(:current).returns(shop)
    ShopifyAPI::Order.stubs(:find).with('1').returns(order)
    
    login_session(:germanbrownies)
  end

  
  context "show" do
    context "without template_id param" do
      should "display templates in sidebar ordered by newest template at the bottom" do
        get :show, {:id => 1}
        assert_response :ok

        templates = assigns(:tmpls)
        assert_equal "Invoice", templates.first.name
      end
    end
    
    context "with template_id param" do
      should "render the preview of the provided template for this order" do
        get :show, {:id => 1, :template_id => @invoice.id, :format => 'js'}
        assert_response :ok
      end
    end
  end
  
  
  context "not logged in" do
    should "redirect to index action if no shop is provided" do
      get :show, {:id => 1}, {}
      assert_redirected_to :controller => 'login', :action => 'index'
    end
    
    should "redirect to authenticate action if shop is provided" do
      get :show, {:id => 1, :shop => "german-brownies.myshopify.com"}, {}
      assert_redirected_to :controller => 'login', :action => 'index', :shop => "german-brownies.myshopify.com"
    end
  end
  
  
  context "already logged in" do
    should "render show action if no different shop is provided" do
      get :show, {:id => 1}
      assert_response :ok
      assert_template 'show'
    end

    should "render show action if same shop is provided" do
      get :show, {:id => 1, :shop => "german-brownies.myshopify.com"}
      assert_response :ok
      assert_template 'show'
    end

    should "render show action if same shop name (without full url) is supplied" do
      get :show, {:id => 1, :shop => "german-brownies"}
      assert_template 'show'
    end
    
    should "redirect to authenticate action if different shop is provided" do
      get :show, {:id => 1, :shop => "american-brownies.myshopify.com"}
      assert_redirected_to :controller => 'login', :action => 'index', :shop => "american-brownies.myshopify.com"
    end
  end
  
  
  context "without safe param" do
    should "NOT set save mode in controller" do
      get :show, {:id => 1}
      assert_not assigns(:safe)
    end
    
    should "should render javascript in templates" do
      get :show, {:id => 1, :template_id => @js_template, :format => 'js'}
      assert_response_include "<script type=\"text/javascript\">"
    end
  end


  context "with safe param" do
    should "set save mode in controller" do
      get :show, {:id => 1, :safe => true}
      assert assigns(:safe)
    end
    
    should "should NOT render javascript in templates" do
      get :show, {:id => 1, :template_id => @js_template, :safe => true, :format => 'js'}
      assert_not @response.body.include?("<script type=\"text/javascript\">")
    end    
  end
  
end