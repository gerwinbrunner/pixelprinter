module ShopifyAPI
  module PriceConversion
    def to_cents(amount)
      (amount.to_f * 100).to_i
    end  
  end

  
  class Shop < ActiveResource::Base
    cattr_accessor :cached
    
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
    
    def street
      string = address1
      string += " #{address2}" if address2
      string
    end
  end
  
  class ShippingAddress < Address
  end

  class BillingAddress < Address
  end         

  class Order < ActiveResource::Base
    include OrderCalculations
    include PriceConversion
    
    def shipping_line
      case shipping_lines.size
      when 0
        nil
      when 1
        shipping_lines.first
      else
        title = shipping_lines.collect(&:title).to_sentence
        price = shipping_lines.to_ary.sum(&:price)
        {:title => title, :price => to_cents(price)}
      end
    end
          
    def to_liquid
      fulfilled, unfulfilled = line_items.partition {|item| item.fulfilled?}
      shop = Shop.cached
      { 
        'id'                => id,
        'created_at'        => created_at,
        'name'              => name, 
        'email'             => email,
        'gateway'           => gateway,
        'order_name'        => name, 
        'order_number'      => number, 
        'shop_name'         => shop.name,
        'subtotal_price'    => to_cents(subtotal_price),
        'total_price'       => to_cents(total_price),
        'tax_price'         => to_cents(total_tax),
        'tax_lines'         => tax_lines,
        'shipping_price'    => to_cents(shipping_line.price),
        'shipping_address'  => shipping_address, 
        'billing_address'   => billing_address, 
        'line_items'        => line_items,
        'fulfilled_line_items' => fulfilled,
        'unfulfilled_line_items' => unfulfilled,
        'shipping_methods'  => shipping_lines,
        'shipping_method'   => shipping_line,
        'note'              => note,
        'attributes'        => note_attributes, 
        'customer'          => {'email' => email, 'name' => billing_address.name},
        'shop'              => shop.to_liquid
      }
    end    
    
    private
    
    def note_attributes
      return nil unless super.is_a?(ActiveResource::Base)
      [super.attributes['note_attribute']].flatten.inject({}) do |memo, attr|
        memo[attr.name] = attr.value
        memo
      end
    end
  end
  
  class LineItem < ActiveResource::Base
    include PriceConversion

    def to_liquid
      {
        'id'         => id, 
        'title'      => name, 
        'price'      => to_cents(price), 
        'line_price' => (to_cents(price) * quantity), 
        'quantity'   => quantity,
        'sku'        => sku,
        'grams'      => grams,
        'vendor'     => vendor,
        'variant_id' => variant_id,
        'variant'    => lambda { variant },
        'product'    => lambda { product }        
      }
    end
    
    def variant
      @variant ||= Variant.lookup(variant_id)
    end
    
    def product
      @product ||= Product.lookup(variant.product_id)
    end
  end       


  class Product < ActiveResource::Base
    def self.lookup(id)
      Rails.cache.fetch("products/#{id}", :expires_in => 1.hour) do
        find(id)
      end
    end
    
    # truncated (as opposed to Shopify's model) for simplicity
    def to_liquid
      {
        'id'                      => id,
        'title'                   => title,
        'handle'                  => handle,
        'description'             => body_html,
        'vendor'                  => vendor,
        'type'                    => product_type,
        'variants'                => variants, 
        'images'                  => images
      }
    end
  end
  
  class Image < ActiveResource::Base
    def to_liquid      
      {'src' => src.match(/\/(products\/.*)\?/)[0]}
    end
  end
  
  
  class Variant < ActiveResource::Base
    include PriceConversion

    def self.lookup(id)
      Rails.cache.fetch("variants/#{id}", :expires_in => 1.hour) do
        find(id)
      end
    end

    # truncated (as opposed to Shopify's model) for simplicity
    def to_liquid
      { 
        'id'                 => id, 
        'title'              => title,
        'option1'            => option1,
        'option2'            => option2,
        'option3'            => option3,
        'price'              => to_cents(price), 
        'weight'             => grams, 
        'compare_at_price'   => to_cents(compare_at_price), 
        'inventory_quantity' => inventory_quantity, 
        'sku'                => sku 
      }
    end
  end


  class ShippingLine < ActiveResource::Base
    include PriceConversion

    def to_liquid
      {'title' => title, 'price' => to_cents(price)}
    end
  end
end