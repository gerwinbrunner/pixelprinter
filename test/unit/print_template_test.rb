require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'
    @local_shop = Shop.create(:name => "My Shop")
    @remote_us_shop       = shop('shop.xml', {'currency' => "USD", 'money_format' => "$ {{amount}}"})
    @remote_european_shop = shop('shop.xml', {'currency' => "EUR", 'money_format' => "&euro;{{amount}}"})
  end

  should "not allow the same name for the same shop" do
    assert @local_shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert !@local_shop.templates.create(:name => "My name", :body => "something else").valid?
  end

  should "allow the same name for different shops" do
    assert @local_shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert Shop.create(:name => "My other Shop").templates.create(:name => "My name", :body => "something else").valid?
  end
  
  
  context "#load_from_file!" do
    should "not create new record if saved already with same name" do
      template = @local_shop.templates.new
      assert template.new_record?
      # saving should fail, because other tests already created an instance in the DB (no duplicate names!)
      assert !template.load_from_file!(:invoice)
    end
    
    should "save body and name from that serialized template" do
      template = @local_shop.templates.new
      template.load_from_file!(:invoice)
      assert_equal 'invoice', template.name
      assert_equal File.read("#{RAILS_ROOT}/db/printing/invoice.liquid"), template.body
    end
  end
  
end