class PrintTemplate < ActiveRecord::Base
  belongs_to :shop
  has_many :versions, :class_name => 'PrintTemplateVersion', :dependent => :delete_all, :order => 'version DESC'
  
  validates_presence_of :body, :shop_id
  validates_length_of   :name, :within => 2..24
  validates_length_of   :body, :maximum => 64.kilobytes, :message => 'cannot exceed 64kb in length'
  validates_uniqueness_of :name, :scope => :shop_id

  before_update :store_current_version
  
  attr_protected :shop_id
  default_scope :order => "id ASC"

  MAX_TEMPLATES_PER_SHOP   = 10
  TOO_MUCH_TEMPLATES_ERROR = "Maximum number of templates is #{MAX_TEMPLATES_PER_SHOP}! You need to delete another template before you are able to create a new one."
  
    
  def self.create_from_file(template_name)
    content = File.read("#{RAILS_ROOT}/db/printing/#{template_name}.liquid")
    create(:name => template_name.to_s.gsub(/[_-]/, ' ').capitalize, :body => content)
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

  
  def highest_version_number
    versions.maximum(:version) || 0
  end
  
  def version_numbers
    @version_numbers ||= versions.find(:all, :select => [ "version" ], :order => 'version DESC').collect(&:version)
  end

  def rollback(version)
    if version = versions.find_by_version(version)
      self.body = version.body
    else
      raise ActiveRecord::RecordNotFound, "Could not find version #{version}"
    end
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

  
  private  

  def store_current_version
    return unless body_changed?
    
    versions.create(:body => body_was, :version => highest_version_number + 1)
  end  
end
