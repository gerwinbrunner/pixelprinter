module ShopifyAPI
  class Shop < ActiveResource::Base
#    def settings
#      {:money_format => "whatever"}
#    end
    
    def to_liquid
      {
        'name'     => name,
        'email'    => email,
        'address'  => address1,
        'city'     => city,
        'zip'      => zip,
        'country'  => country,
        'phone'    => phone,
        'province' => province,
        'owner'    => shop_owner
      }
    end
  end               

  class Address < ActiveResource::Base
    def to_liquid
      address_hash = Hash.from_xml(to_xml)
      # is either shipping address or billing address
      address_hash[address_hash.keys.first].merge('street' => street)
    end
    
    # TODO: remove Address#street as it will get exported from Shopify
    def street
      street  = address1
      street += ", #{address2}" unless address2.blank?
      street  
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
        'subtotal_price'    => cents(subtotal_price),
        'total_price'       => cents(total_price),
        'tax_price'         => cents(total_tax),
        'shipping_price'    => cents(shipping_line.price),
        'shipping_address'  => shipping_address, 
        'billing_address'   => billing_address, 
        'line_items'        => line_items,
        'fulfilled_line_items' => fulfilled,
        'unfulfilled_line_items' => unfulfilled,
        'shipping_method'   => shipping_line,
        'note'              => note_body,
        'attributes'        => note_attributes, 
        'customer'          => {'email' => email, 'name' => billing_address.name},
        'shop'              => Shop.current.to_liquid
      }
    end

    def url
      "#{ShopifyAPI::Session.protocol}://#{ShopifyAPI::Shop.current.domain}/admin/orders/#{id}"
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
   
    def cents(amount)
      (amount * 100).to_i
    end
  end
  
  class LineItem < ActiveResource::Base 
    def to_liquid
      hash = as_hash
      hash['variant_id'] = variant_id    
      #hash['variant'] = Proc.new { Variant.find(variant_id) rescue nil }         
      #hash['product'] = Proc.new { Product.find(hash['variant'].product_id) rescue nil } 
      hash.to_liquid
    end
    
    private
    
    def as_hash
      {
        'id'         => id, 
        'title'      => name, 
        'price'      => price.to_i * 100, 
        'line_price' => (price * quantity), 
        'quantity'   => quantity,
        'sku'        => sku,
        'grams'      => grams,
        'vendor'     => vendor
      }
    end
  end       


  class Product < ActiveResource::Base
    # truncated (as opposed to Shopify's model) for simplicity
    def to_liquid
      {
        'id'                      => id,
        'title'                   => title,
        'handle'                  => handle,
        'description'             => body_html,
        'vendor'                  => vendor,
        'type'                    => product_type
      }
    end
  end
  
  
  class Variant < ActiveResource::Base
    # truncated (as opposed to Shopify's model) for simplicity
    def to_liquid
      { 
        'id'                 => id, 
        'title'              => title,
        'trait1'             => trait1,
        'trait2'             => trait2,
        'trait3'             => trait3,
        'price'              => price, 
        'weight'             => grams, 
        'compare_at_price'   => compare_at_price, 
        'inventory_quantity' => inventory_quantity, 
        'sku'                => sku 
      }
    end
  end


  class ShippingLine < ActiveResource::Base
    def to_liquid
      {'title' => title, 'price' => price}
    end
  end
end