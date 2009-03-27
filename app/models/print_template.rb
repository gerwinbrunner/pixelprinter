class PrintTemplate < ActiveRecord::Base
  belongs_to :shop
  
  validates_presence_of :body, :shop_id
  validates_length_of   :name, :within => 2..32
  
  attr_protected :shop_id

  def parse
    Liquid::Template.parse(body)
  end
    
  def check_syntax
    parse
    return true
  rescue Liquid::SyntaxError => e
    return false, e.message
  end
  
  def render(assigns)
    parse.render(assigns, EmailMoneyFilter)
  end

  def from_file(template_name)
    content = File.read("#{RAILS_ROOT}/db/printing/#{template_name}.liquid")
    self.update_attributes :name => template_name.to_s, :body => content
  end
  
protected 
  def validate
    success, message = check_syntax
    errors.add_to_base message unless success
  end
  
end
