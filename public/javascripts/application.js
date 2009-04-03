// Called when the order is shown, and each time a template checkbox has changed
function checkSelectedTemplates(order) {
	checkAllTemplatePreviews(order);
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

function checkAllTemplatePreviews(order) {
	$("#selected-templates :checkbox").each(function() {
		toggleTemplatePreview(order, this);
	});
}

// Shows the rendered preview for a template if the corresponding checkbox is selected, else it hides it.
// If the preview has not already been rendered it inserts it via AJAX, else it just shows the hidden preview.
function toggleTemplatePreview(order, checkbox) {
	var	template = checkbox.value;
	var templatePreview = $("#template-preview-" + template);
  if (checkbox.checked == true) {
    if (templatePreview.length == 1) { 
      templatePreview.show();
    } else { 
			$("#preview-status").show();
      $("#preview-" + template).load("/print_templates/show/" + template + "&order_id=" + order, 
																		null, function() { $("#preview-status").hide(); });
    }
  } else { 
    templatePreview.hide();
  }
}