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
end
