module ShopFilter
      
  def asset_url(input)    
    "http://static.shopify.com/s/files/#{resources_dir}/assets/#{input}"
  end

  def files_url(input)    
    "http://static.shopify.com/s/files/#{resources_dir}/files/#{input}"
  end


  def global_asset_url(input)
    req = @context.registers[:request]
    "http://static.shopify.com/s/global/#{input}"
  end
  
  def shopify_asset_url(input)
    "http://static.shopify.com/s/shopify/#{input}"
  end
  
  def script_tag(url)
    %(<script src="#{url}" type="text/javascript"></script>)
  end

  def stylesheet_tag(url, media="all")
    %(<link href="#{url}" rel="stylesheet" type="text/css"  media="#{media}"  />)
  end
       
  def link_to(link, url, title="")
    %|<a href="#{url}" title="#{title}">#{link}</a>|
  end
  
  def img_tag(url, alt="")
    %|<img src="#{url}" alt="#{alt}" />|  
  end  
  
  def link_to_vendor(vendor)
    if vendor
      link_to vendor, url_for_vendor(vendor), vendor
    else
      'Unknown Vendor'
    end
  end
  
  def link_to_type(type)
    if type
      link_to type, url_for_type(type), type
    else
      'Unknown Vendor'
    end
  end
  
  def url_for_vendor(vendor_title)
    "#{ShopifyAPI::Shop.cached.url}/admin/collections/vendors?q=#{CGI.escape(vendor_title)}"
  end

  def url_for_type(type_title)
    "#{ShopifyAPI::Shop.cached.url}/admin/collections/types?q=#{CGI.escape(type_title)}"
  end

  
  def product_img_url(url, style = 'small')
    
    unless url =~ /^\/?products\/([\w\-\_]+)\.(\w{2,4})/
      raise ArgumentError, 'filter "size" can only be called on product images'
    end
                
    case style
    when 'original'
      "http://static.shopify.com/s/files/#{resources_dir}/#{url}"
    when 'grande', 'large', 'medium', 'small', 'thumb', 'icon'
      "http://static.shopify.com/s/files/#{resources_dir}/products/#{$1}_#{style}.#{$2}"
    else
      raise ArgumentError, 'valid parameters for filter "size" are: original, grande, large, medium, small, thumb and icon '      
    end
  end
  
  # Accepts a number, and two words - one for singular, one for plural
  # Returns the singular word if input equals 1, otherwise plural
  def pluralize(input, singular, plural)
    input == 1 ? singular : plural
  end
  
  def resources_dir
    shop_id = ShopifyAPI::Shop.cached.id 
    resources_dir = "1/" << ("%08d" % shop_id).scan(/..../).join('/')    
  end
      
end
