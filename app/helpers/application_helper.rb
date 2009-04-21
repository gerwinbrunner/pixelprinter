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
      title = %(<h2 class="header"><a href="#{@title_url}" target="_blank">#{h(@title)}</a></h2>)
    else
      title = %(<h2 class="header">#{h(@title)}</h2>)
    end
    title << %(\n<p class="description">#{@title_description}</p>) if @title_description
    title
  end


  def sidebar(&block)
    @sidebar_enabled = true
    content_for :sidebar, &block
  end

  
  def nav_link(url, label = "Go back", options = {})
    @links ||= []
    @links << link_to(label, url, options)
  end

  def nav_linklist_html
    linklist = ''
    if @links
      linklist << %(<ul class="linklist">\n)
    
      @links.each_with_index do |link, index|
        linklist << "<li>#{link}</li>"
        linklist << " | " if index < @links.size - 1
      end
      linklist << "</ul>"
    end
    linklist
  end

  
  def add_template_selector_options(selected_template, order, tmpls)
    ids   = tmpls.map(&:id).map{|var| "'#{var}'"}.join(", ")
    names = tmpls.map(&:name).map{|var| "'#{var}'"}.join(", ")
    "addTemplateSelectorOptions('#{selected_template}', '#{order}', [#{ids}], [#{names}]);"
  end
end
