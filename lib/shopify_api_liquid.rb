module ShopifyAPI  
  class Shop
  end               

  class Address < ActiveResource::Base
    def to_liquid
      address = Hash.from_xml(to_xml)
      # is either shipping address or billing address
      address[address.keys.first]
    end
  end
  
  class ShippingAddress < Address
  end

  class BillingAddress < Address
  end         

  class Order < ActiveResource::Base
    include OrderCalculations
    
    def to_liquid
      fulfilled, unfulfilled = line_items.partition {|item| item.fulfilled?}
      { 
        'name'              => name, 
        'email'             => email,
        'gateway'           => gateway,
        'order_name'        => name, 
        'order_number'      => number, 
        'shop_name'         => Shop.current.name,
        'subtotal_price'    => subtotal_price,
        'total_price'       => total_price,
        'tax_price'         => total_tax,
        'shipping_price'    => shipping_price,      
        'shipping_address'  => shipping_address, 
        'billing_address'   => billing_address, 
        'line_items'        => line_items,
        'fulfilled_line_items' => fulfilled,
        'unfulfilled_line_items' => unfulfilled,
        'shipping_method'   => shipping_line,
        'note'              => note_body,
        'attributes'        => note_attributes, 
        'customer'          => {'email' => email, 'name' => billing_address.name}
      }
    end
    
    private

    # additional methods from original Ordel model in shopify, needed for to_liquid

    def note_body 
      note.to_s.gsub(/^\t.*$/, '').strip
    end

    def note_attributes
      values = {}
      note.to_s.scan(/^\t([^\:]+)\:\ (.*)$/) do |matches|
        values[matches[0]] = matches[1].to_s.strip
      end
      values
    end
    
  end

end