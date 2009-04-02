require 'faker'

module ExampleOrder
  
  def self.included(base)    
    base.extend(ClassMethods)    
  end
  
  module ClassMethods    
    def example
      order_xml = File.read(RAILS_ROOT + '/db/example_order.xml')
      ShopifyAPI::Order.new(Hash.from_xml(order_xml)['order'])
    end
  end
end