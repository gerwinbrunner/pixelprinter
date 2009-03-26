module OrdersHelper
  
  # send an AJAX request only once to insert the preview, and then hide/show on subsequent clicks
  def template_selection_listener(order, tmpl)
    %Q[
      var templatePreview = $("#template-preview-#{tmpl.id}");
      if (this.checked == true) {
        if (templatePreview.length == 1) { 
          templatePreview.show();
        } else { 
          $.get('/orders/show', {checked: this.checked, id: #{order.id}, template_id: #{tmpl.id}}, null, 'script');
        }
      } else { 
        templatePreview.hide();
      }
      checkSelectedTemplates();
    ]
  end
end