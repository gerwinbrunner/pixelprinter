class PrintTemplate < ActiveRecord::Base
  belongs_to :shop
  
  validates_presence_of :body, :shop_id
  validates_length_of   :name, :within => 2..24
  validates_uniqueness_of :name, :scope => :shop_id
  
  attr_protected :shop_id

  MAX_TEMPLATES_PER_SHOP   = 10
  TOO_MUCH_TEMPLATES_ERROR = "Maximum number of templates is #{MAX_TEMPLATES_PER_SHOP}! You need to delete another template before you are able to create a new one."

  def self.create_from_file(template_name)
    content = File.read("#{RAILS_ROOT}/db/printing/#{template_name}.liquid")
    create(:name => template_name.to_s.capitalize, :body => content)
  end
  
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
    # render! will not silently ignore errors, but raise an Exception
    parse.render!(assigns, MoneyFilter)
  end

protected 
  def validate
    if shop.templates.count > MAX_TEMPLATES_PER_SHOP
      errors.add_to_base(TOO_MUCH_TEMPLATES_ERROR)
    else
      success, message = check_syntax
      errors.add_to_base(message) unless success
    end
  end
  
end
