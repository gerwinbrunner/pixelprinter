// gives you: Templates.checkAll()
Templates = function(order) {
	var _order = null
	
	/* private methods */
	var togglePrintButton = function() {
		var selected = $("#selected-templates :checkbox:checked").length;
	  if (selected > 0) {
	    $("#print-button").show();
	  } else {
	    $("#print-button").hide();
	  }
	}
	
	var showPreviewForSelectedTemplates = function() {
		$("#selected-templates :checkbox").each(function() {
			toggleTemplatePreview(this);
		})
	}
	
	var toggleTemplatePreview = function(checkbox) {
		var	template = checkbox.value;
		var templatePreview = $("#template-preview-" + template);
	  if (checkbox.checked == true && checkbox.disabled == false) {
	    if (templatePreview.length == 1) { 
	      templatePreview.show();
	    } else { 
				checkbox.disabled = true;
				Status.show();
	      $("#preview-" + template).load("/print_templates/" + template + "?order_id=" + _order + "&inline=true", null, 
					function() { 
						Status.hide(); 
						checkbox.disabled = false; 
					}
				);
	    }
	  } else { 
	    templatePreview.hide();
	  }
	}
	
	/* public methods */
	return {
		checkAll: function(order) {
			_order = order
			showPreviewForSelectedTemplates();
			togglePrintButton();
		}
	}
}()


// gives you: Dialog.options()
Dialog = function() {
	return {
		options: function(otherOptions) {
			var dialogOptions = {
		  	modal: true,
		  	width: 500,
				height: 550
			}
			if (typeof(otherOptions) != 'undefined') {
				dialogOptions = jQuery.extend(dialogOptions, otherOptions);
			}
			return dialogOptions
		}
	}
}()


// gives you: Status.show() and Status.hide()
Status = function() {
	return {
		show: function(text, type) {
			var text = (typeof(text) != 'undefined') ? text : 'Loading...'
			var type = (typeof(type) != 'undefined') ? type : 'notice'
			jQuery.noticeAdd({text: text, type: type})
		},
		
		hide: function() {
			jQuery.noticeRemove($('.notice-item-wrapper'))
		}
	}
}()


// TODO: Maybe rewrite/reuse this function to add template selecting to preview box, else get rid of this code
function addTemplateSelectorOptions(selectedTemplate, order, templateIDs, templateNames) {
	var selecta = $("#template-selector");
	var selections = jQuery.map(templateIDs, function(id, index){
		return "<option value='" + id + "'" + (selectedTemplate == id ? " selected=true" : "") +  ">" + templateNames[index] + "</option>";
	});
	selecta.html(selections.join(" "));
	
	selecta.bind('change', function(e) {
		var template = e.target.value;
		Status.show();
		selecta.disable();
		$("#facebox .content").load("/print_templates?id=" + template + "&order_id=" + order, 
			null, function() { Status.hide(); selecta.enable(); } 
		);
	});
}