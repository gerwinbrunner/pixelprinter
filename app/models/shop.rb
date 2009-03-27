class Shop < ActiveRecord::Base
  has_many :templates, :class_name => "PrintTemplate"

  after_create :create_base_templates


  private
  
  # Create 3 templates as a starting point for the user
  def create_base_templates
    templates.new.from_file(:invoice)
  end
end
