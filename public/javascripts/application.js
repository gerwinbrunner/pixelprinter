// gives you: Templates.checkAll()
Templates = function() {
	var _order = null
	
	/* private methods */
	var togglePrintButton = function() {
		var selected = $("#selected-templates :checkbox:checked").length
	  if (selected > 0) {
	    $("#print-button").show()
	  } else {
	    $("#print-button").hide()
	  }
	}
	
	var showPreviewForSelectedTemplates = function() {
		$("#selected-templates :checkbox").each(function() {
			toggleTemplatePreview(this)
		})
	}
	
	var toggleTemplatePreview = function(checkbox) {
		var	template = checkbox.value
		var templatePreview = $("#template-preview-" + template)
	  if (checkbox.checked == true && checkbox.disabled == false) {
	    if (templatePreview.length == 1) { 
	      templatePreview.show()
	    } else { 
				checkbox.disabled = true
				Status.show()

				var url = "/print_templates/preview?id=" + template + "&order_id=" + _order
				var preview = "<div id='template-preview-" + template + "'><div class='template-preview'><iframe src='" + url + "'id='iframe-preview-" + template + "' onload='IFrame.resize(this)' scrolling='no' width='100%' frameborder='0' ></iframe></div></div>"
				
				checkbox.disabled = false
				Status.hide()
	      $("#preview-" + template).html(preview)
	    }
	  } else { 
	    templatePreview.hide()
	  }
	}
	
	/* public methods */
	return {
		checkAll: function(order) {
			_order = order
			showPreviewForSelectedTemplates()
			togglePrintButton()
		}
	}
}()


// gives you: Dialog.options()
Dialog = function() {
	var dlg = "#modal-dialog"

	var options = function(otherOptions) {
		var dialogOptions = {
	  	modal: true,
	  	width: 500,
			height: 550
		}
		
		dialogOptions = jQuery.extend(dialogOptions, otherOptions)
		return dialogOptions
	}

	return {
		open: function(title, otherOptions) {
			var otherOptions = (typeof(otherOptions) != 'undefined') ? otherOptions : {}
			var opts = options(otherOptions)
			$(dlg).dialog(jQuery.extend(opts, {title: title}))
			$(dlg).dialog('open')
		},
		
		close: function() {
			$(dlg).dialog('destroy')
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


// gives you: IFrame.resize()
IFrame = function() {
	return {
		resize: function(iframe) {
			var innerDoc = iframe.contentDocument ? iframe.contentDocument : iframe.contentWindow.document
			iframe.height = innerDoc.body.scrollHeight + 35
		}
	}
}()