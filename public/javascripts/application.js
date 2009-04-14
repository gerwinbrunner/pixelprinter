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
  if (checkbox.checked == true && checkbox.disabled == false) {
    if (templatePreview.length == 1) { 
      templatePreview.show();
    } else { 
			checkbox.disabled = true;
			$("#preview-status").show();
      $("#preview-" + template).load("/print_templates/preview/" + template + "&order_id=" + order, 
				null, 
				function() { 
					$("#preview-status").hide(); 
					checkbox.disabled = false; 
				}
			);
    }
  } else { 
    templatePreview.hide();
  }
}


function togglePreviewLinkStatus(active) {
	if (active) {
		$("#main-buttons").hide();
		$("#preview-status").show();
	} else {
		$("#main-buttons").show();
		$("#preview-status").hide();
	}
}


function addTemplateSelectorOptions(selectedTemplate, order, templateIDs, templateNames) {
	var selecta = $("#template-selector");
	var selections = jQuery.map(templateIDs, function(id, index){
		return "<option value='" + id + "'" + (selectedTemplate == id ? " selected=true" : "") +  ">" + templateNames[index] + "</option>";
	});
	selecta.html(selections.join(" "));
	
	selecta.bind('change', function(e) {
		var template = e.target.value;
		$("#preview-status").show();
		selecta.disable();
		$("#facebox .content").load("/print_templates/preview?id=" + template + "&order_id=" + order, 
			null, function() { $("#preview-status").hide(); selecta.enable(); } 
		);
	});
}


Template = function() {
	/* private class variables */
  var div      = "#modal-dialog"
	var status   = "#preview-status"
	var tmpl     = null
	
	/* private class methods */
	var dialogOptions = function(type) {
		var options = {
		  modal: true,
		  autoOpen: false,
		  width: 500,
		  height: 600,
			title: type
		}
		return jQuery.extend(options, buttons(type));
	}
	
	var formParams = function() {
		return {
			"print_template[name]": $("#print_template_name").val(), 
			"print_template[body]": $("#print_template_body").val(), 
			"authenticity_token":   $("#print_template_form input[name=authenticity_token]").val()
		}
	}
	
	var buttons = function(type) {
		var buttonOptions = {}
		if (type == "Preview") {
			buttonOptions = {
				"Print": function() { window.print() },
	    	"Edit": function() {
					$(div).dialog('close')
					Template.edit()
				}
			} 
		} else if (type == "Edit") {
			buttonOptions = { 
			  "Save": function() { 
					$(status).show()
					$.post("/print_templates/" + tmpl, $.extend(formParams(), {_method: "put"}), null, "script")
				}
			}	
		}	else if (type == "Create") {
			buttonOptions = {
		  	"Save": function() { 
					$(status).show()
					$.post("/print_templates", formParams(), null, "script")
				}
			}
		}
		return { buttons: buttonOptions}
 	}
	
  var loadDialog = function(type, url) {
		$(status).show()
		$(div).load(url, function() { 
			$(status).hide()
			$(div).dialog('destroy') // builds dialog from the ground up (make sure there are no leftovers)
			$(div).dialog(dialogOptions(type)).dialog('open')
		})
  }

	/* public class methods */
  return {
    preview: function(template, order) {
      tmpl = template
      loadDialog("Preview", "/print_templates/" + tmpl + "/preview?order_id=" + order)
    },

		edit: function(template) {
			loadDialog("Edit", "/print_templates/" + tmpl + "/edit")
		},
		
		create: function(order) {
			loadDialog("Create", "/print_templates/new")
		}
  }
}()