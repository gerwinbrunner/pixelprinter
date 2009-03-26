require File.dirname(__FILE__) + '/../test_helper'

class PrintTemplateTest < ActiveSupport::TestCase
  should_belong_to :shop
  should_validate_presence_of :body
  should_ensure_length_in_range :name, 2..32
  should_not_allow_mass_assignment_of :shop_id
  
  def setup
    @shop = Shop.create
  end
  
  context "#load_template" do
    should "save body and name from that template" do
      template = @shop.templates.new
      template.load_template(:invoice)
      assert !template.new_record?
      assert_equal 'invoice', template.name
      assert_equal File.read("#{RAILS_ROOT}/db/printing/invoice.liquid"), template.body
    end
  end
  
end