require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplatesControllerTest < ActionController::TestCase
  tests PrintTemplatesController
 
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'
    ShopifyAPI::Shop.stubs(:current).returns(shop)
    
    @session = login_session(:germanbrownies)
    @tmpl = print_templates(:quotation_mark_in_title)
    @tmpl_params = {:print_template => {:name => @tmpl.name, :body => @tmpl.body, :shop_id => @tmpl.shop_id}}
    @params = {:format => :js}
  end
  
  
  context "create" do
    before do
      @new_template_params = {:print_template => {:name => "Quotation mark's test", :body => @tmpl.body, :shop_id => @tmpl.shop_id}}
    end
    
    should "have no problems with single quotation marks in title" do
      post :create, @params.merge(@new_template_params), @session
      assert_response_include "Messenger.notice(\"Successfully created new template named Quotation mark's test.\");"
    end
  
    should "insert a checkbox and a label via JS" do
      post :create, @params.merge(@new_template_params), @session
      tmpl = assigns(:tmpl)

      # make sure the quotes are escaped (via inspect), and remove the very first and last quote
      assert_response_include "<input id=\"template-checkbox-#{tmpl.id}\"".inspect[1..-2]
      assert_response_include "<label for=\"template-checkbox-#{tmpl.id}\">Quotation mark's test</label>".inspect[1..-2]
    end    
    
    should "insert an empty preview container at the end of the preview div on the page" do
      post :create, @params.merge(@new_template_params), @session
      tmpl = assigns(:tmpl)

      assert_response_include "$(\"#preview\").append(\"<div id='preview-#{tmpl.id}'></div>\");"
    end    
    
  end


  context "update" do
    should "have no problems with single quotation marks in title" do
      put :update, @params.merge(@tmpl_params.merge(:id => @tmpl.id)), @session
      assert_response_include "Messenger.notice(\"Successfully updated template named #{@tmpl.name}.\");"
    end
  end
  
end