require File.dirname(__FILE__) + '/../test_helper'

class LoginControllerTest < ActionController::TestCase
  tests LoginController
 
  before do
    @request_origin = "http://coming.from/here"
    @request.env["HTTP_REFERER"] = @request_origin
  end
  
  context "when not logged in" do
    context "index" do
      should "show index template" do
        get :index
        assert_template 'index'
      end
    
      should "redirect to authenticate action if shop is provided" do
        get :index, :shop => "german-brownies"
        assert_redirected_to :action => 'authenticate', :shop => "german-brownies"
      end
    end

    context "authenticate" do
      should "redirect back if no shop is provided" do
        get :authenticate
        assert_redirected_to @request_origin
      end
    
      should "redirect back if blank shop is provided" do
        get :authenticate, {:shop => ''}
        assert_redirected_to @request_origin
      end
    end
  end
  
  
  context "when logged in" do
    before do
      login_session(:germanbrownies)
    end
    
    context "authenticate" do
      should "redirect back if no shop is provided" do
        get :authenticate
        assert_redirected_to @request_origin
      end
      
      should "redirect to shop's permission url if a shop is provided" do
        get :authenticate, {:shop => 'german-brownies'}
        assert_redirected_to ShopifyAPI::Session.new('german-brownies').create_permission_url
      end
    end
    
    context "finalize" do
      before do
        @return_url = "/orders?id=123&shop=german-brownies"
      end

      should "redirect to stored return url in session" do
        get :finalize, {:shop => 'german-brownies', :t => '1234'}, @request.session.merge(:return_to => @return_url)
        assert_redirected_to @return_url
      end
    end
  end
end