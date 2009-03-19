class Shop < ActiveRecord::Base
  has_many :templates, :class_name => "PrintTemplate"

  after_create :create_base_templates
  
  def orders
    ShopifyAPI::Order.find(:all, :params => {:order => "created_at DESC" })
  end
  
#  private
  
  # Create 3 templates as a starting point for the user
  def create_base_templates
    templates.new.load_template(:invoice)
  end
end
