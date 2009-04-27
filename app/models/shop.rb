class Shop < ActiveRecord::Base
  has_many :templates, :class_name => "PrintTemplate"

  after_create :create_base_templates


  private
  
  # Create 3 templates as a starting point for the user
  def create_base_templates
    templates.new.load_from_file!(:invoice)
    templates.new.load_from_file!(:package_slip)
    templates.new.load_from_file!(:all_variables_used)
  end
end
