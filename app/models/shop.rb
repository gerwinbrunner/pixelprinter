class Shop < ActiveRecord::Base
  has_many :templates, :class_name => "PrintTemplate"

  after_create :create_base_templates


  private
  
  # Create 3 templates as a starting point for the user
  def create_base_templates
    templates.create_from_file(:invoice).update_attribute(:default, true)
    t = templates.create_from_file(:packing_slip)
    puts t.errors.full_messages
    t2 = templates.create_from_file(:variable_reference)
    puts t2.errors.full_messages
  end
end
