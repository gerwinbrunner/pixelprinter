module TabsHelper
  # Create a tab as <li> and give it the id "current" if the current controller matches that tab
  def tab(label, url)
    options = {}
    options[:id] = "current" if controller.controller_name =~ /#{url[:controller]}/
    content_tag :li, link_to(label || name.to_s.capitalize, url, options)
  end
end