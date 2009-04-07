# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(new_value = nil, options = {})
    @title = new_value if new_value
    @title_url = options[:url] if options[:url]
    @title_description = options[:description] if options[:description]
    @title
  end
  
  def title_html
    if @title_url
      title = %(<h2><a href="#{@title_url}" target="_blank">#{h(@title)}</a></h2>)
    else
      title = %(<h2>#{h(@title)}</h2>)
    end
    title << %(\n<p class="description">#{@title_description}</p>) if @title_description
    %(<div id="title">#{title}</div>)
  end

  def nav_link(url, label = "Go back", options = {})
    @links ||= []
    @links << link_to(label, url, options)
  end

  def nav_linklist_html()
    linklist = %(<ul class="linklist">\n)
    if @links
      @links.each_with_index do |link, index|
        linklist << "<li>#{link}</li>"
        linklist << " | " if index < @links.size - 1
      end
    end
    linklist << "</ul>"
  end
  
  def preview_status
    content_tag :p, :id => "preview-status" do
      image_tag("status.gif") + " Generating preview..."
    end
  end
  
  def preview_link(template=nil, order=nil, options={})
    url = {:controller => 'print_templates', :action => 'preview'}
    url.merge!(:id => template) if template
    url.merge!(:order_id => order) if order
    
    link_to_remote("Preview", {:url => url, :submit => "print_template_form", 
            :loading => "togglePreviewLinkStatus(true);",
            :complete => "jQuery.facebox(request.responseText); togglePreviewLinkStatus(false);", 
            :html => {:id => "preview-link"}}.deep_merge(options))
  end
end
