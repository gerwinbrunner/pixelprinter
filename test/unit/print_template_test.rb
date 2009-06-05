require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'
    @local_shop = shops(:germanbrownies)
    @remote_us_shop       = shop('shop.xml', {'currency' => "USD", 'money_format' => "$ {{amount}}"})
    @remote_european_shop = shop('shop.xml', {'currency' => "EUR", 'money_format' => "&euro;{{amount}}"})
  end

  should "not allow the same name for the same shop" do
    assert @local_shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert_not @local_shop.templates.create(:name => "My name", :body => "something else").valid?
  end

  should "allow the same name for different shops" do
    assert @local_shop.templates.create(:name => "My name", :body => "whatever").valid?
    assert Shop.create(:url => "www.differentshop.com").templates.create(:name => "My name", :body => "something else").valid?
  end
  
  should "not allow more than 10 templates per shop" do
    @local_shop.templates.destroy_all
    10.times do |i|
      assert @local_shop.templates.create(:name => "Template ##{i}", :body => "something").valid?
    end
    assert_not @local_shop.templates.create(:name => "Template #11", :body => "something").valid?
  end
  
  
  context "#create_from_file" do
    should "not create new record if saved already with same name" do
      # saving should fail, because other tests already created an instance in the DB (no duplicate names!)
      assert_not @local_shop.templates.create_from_file(:invoice).valid?
    end
    
    should "save body and name from that serialized template" do
      template = @local_shop.templates.create_from_file(:invoice)
      assert_equal 'Invoice', template.name
      assert_equal File.read("#{RAILS_ROOT}/db/printing/invoice.liquid"), template.body
    end
  end
  
  
  context "#rollback" do
    should "revert the contents of the template to the specified version" do
      template = print_templates(:custom_invoice)
      template.rollback(1)
      assert_equal print_template_versions(:invoice_v1).body, template.body
    end
      
    should "raise ArgumentError when version could not be found" do
      assert_raises(ActiveRecord::RecordNotFound) do
        template = print_templates(:custom_invoice)
        template.rollback(1000)
      end
    end
  end
    
  context "#body" do
    should "not be valid when larger than 64 kb" do
      template = shops(:germanbrownies).templates.build(
                   :name => 'too_large_test',
                   :body => '0' * 65.kilobytes
                 )
      assert !template.valid?
      assert template.errors.on(:body)
    end
  end

  context "#versions" do
    before do
      @packing_slip = print_templates(:packing_slip)
    end

    should "#version_numbers return the correct version numbers" do
      expected = @packing_slip.versions.collect(&:version).sort.reverse
      
      assert_equal expected, @packing_slip.version_numbers  
    end

    should "create version after update" do
      @packing_slip.body += "More data..."
      
      assert_difference 'PrintTemplateVersion.count', +1 do
        @packing_slip.save                                       
      end                         
    end
    
    should "correctly increment version numbers when updating" do
      
      assert_difference "PrintTemplateVersion.count", 2 do
        @packing_slip.body = "First change"
        assert @packing_slip.save
        
        @packing_slip.body = "Second change"
        assert @packing_slip.save
      end
      
      assert_equal [2, 1], @packing_slip.version_numbers
    end
  end
end