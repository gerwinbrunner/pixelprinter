module ShopifyAPI
  class Shop < ActiveResource::Base
    cattr_accessor :cached
    
    def money_format; "${{amount}}" ;end
    def money_with_currency_format; "${{amount}} USD";end
    
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
    
    def shipping_line
      shipping_lines.map(&:title).join(', ')
    end
    
    def to_liquid
      fulfilled, unfulfilled = line_items.partition {|item| item.fulfilled?}
      shop = Shop.cached
      { 
        'name'              => name, 
        'email'             => email,
        'gateway'           => gateway,
        'order_name'        => name, 
        'order_number'      => number, 
        'shop_name'         => shop.name,
        'subtotal_price'    => cents(subtotal_price),
        'total_price'       => cents(total_price),
        'tax_price'         => cents(total_tax),
        'shipping_price'    => cents(shipping_lines.sum(&:price)),
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

    # needed because Shopify API exports prices in decimals (dollar amounts), 
    # but we want integers (cent amounts) for consistency
    def cents(amount)
      (amount * 100).to_i
    end
  end
  
  class LineItem < ActiveResource::Base 
    def to_liquid
      {
        'id'         => id, 
        'title'      => name, 
        'price'      => price.to_i * 100, 
        'line_price' => (price * quantity), 
        'quantity'   => quantity,
        'sku'        => sku,
        'grams'      => grams,
        'vendor'     => vendor,
        'variant_id' => variant_id
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