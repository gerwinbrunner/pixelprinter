// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function checkSelectedTemplates() {
	togglePrintButton();
}

function togglePrintButton() {
	var selected = $("#selected-templates :checkbox:checked").length;
  if (selected > 0) {
    $("#print-button").show();
  } else {
    $("#print-button").hide();
  }
}

function showTemplatePreview(order, template) {
	var templatePreview = $("#template-preview-" + template);
  if (this.checked == true) {
    if (templatePreview.length == 1) { 
      templatePreview.show();
    } else { 
      $.get('/orders/show', {checked: this.checked, id: order, template_id: template}, null, 'script');
    }
  } else { 
    templatePreview.hide();
  }
}