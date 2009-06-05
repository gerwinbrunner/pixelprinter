module PrintTemplateHelper
  def rollback_link(template_name)
    link_to_remote "Older revisions&hellip;", {
        :url => { 
          :action => 'fetch_versions',
          :template_name => template_name
        }, 
        :before => "$('#rollback-link').replaceWith('<span id=\"rollback-link\">Loading&hellip;</span>')", 
        :success => "$('#rollback-link').replaceWith('View revision:')"
      }, { :id => 'rollback-link' }
  end

  def version_options_for_select(versions)
    options = [["Current", ""]]
    options.concat(versions)
    options_for_select(options)
  end
end