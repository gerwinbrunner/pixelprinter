Templates = function() {
	var _order = null;
	var _templates = null;
	
	/* private methods */
	var togglePrintButton = function() {
	  if (_templates.length > 0) {
			$("#print-start").hide();
	    $("#print-button").show();
			var pluralize = _templates.length == 1 ? "template" : "templates"
			$("#template-amount").html(_templates.length + " " + pluralize)

	  } else {
	    $("#print-button").hide();
			$("#print-start").show();
	  }
	}

	var toggleInlinePreview = function(template) {
		// preview iframe, could be already inserted (cached in DOM)
		var templatePreview = $("#iframe-preview-" + template);
		// is template selected?
		if (_templates.indexOf(template) > -1) {
			if (templatePreview.length > 0) { 
	      templatePreview.show();
	    } else {
				loadInlinePreview(template);
			}			
		} else {
			templatePreview.hide();
		}
	}
	
	var loadInlinePreview = function(template) {
		var checkbox = $("#template-checkbox-" + template);
		checkbox.disable();
		Status.loading();

		Callback.prepare(template, function() { 
			checkbox.enable();
			Status.hide();
			IFrame.resizeAll();
		});

		var url = "/orders/" + _order + "/preview?template_id=" + template;
		var preview = "<iframe src='" + url + "' class='template-preview' id='" + "iframe-preview-" + template + "' onload='Callback.trigger(" + template +")' scrolling='no' width='100%' frameborder='0' ></iframe>";
	  $("#preview-" + template).html(preview);
	}
	
	/* public methods */
	return {
		initialize: function(order) {
			_order = order;
			_templates = [];
		},
		
		templateChanged: function(template) {
			togglePrintButton();
			toggleInlinePreview(template);
		},

		updateSelection: function(checkbox) {
			var template = checkbox.val();

			if (checkbox.attr('checked') == true) {
				if (_templates.indexOf(template) == -1)
					_templates.push(template);
			} else {
				_templates.splice(_templates.indexOf(template), 1);
			}

			this.templateChanged(template);
		},
	
		preview: function(template) {
			$.ajax({
	      beforeSend: function(request) { Status.loading(); }, 
	      dataType: 'script', 
	      type: 'get',
	      url: '/orders/' + _order + '?template_id=' + template
	    });
		},

		print: function() {
			$.ajax({
	      url: 	'/orders/' + _order + '/print',
				data: $("#selected-templates").serialize(),
	      type: 'post'
	    });
			window.print();
		},
		
		removeInlinePreview: function(template) {
	  	$("#preview-" + template).empty();

			var checkbox = $("#template-checkbox-" + template);
			if (checkbox.attr('checked')) {
				loadInlinePreview(template);
			}
		}
	}
}();


// gives you: Dialog.open() and Dialog.close()
Dialog = function() {
	var dlg = "#modal-dialog";

	var options = function(otherOptions) {
		var dialogOptions = {
	  	modal: true,
	  	width: 500,
			height: 550
		};
		
		dialogOptions = jQuery.extend(dialogOptions, otherOptions);
		return dialogOptions;
	}

	return {
		open: function(title, otherOptions) {
			var otherOptions = (typeof(otherOptions) != 'undefined') ? otherOptions : {};
			var opts = options(otherOptions);
			$(dlg).dialog(jQuery.extend(opts, {title: title}));
			$(dlg).dialog('open');
		},
		
		close: function() {
			$(dlg).dialog('destroy');
		}
	}
}();


// Status.loading(), Status.notify(), Status.error() and Status.hide()
Status = function() {
	var statusCount = 0;
	
	/* private methods */
	var show = function(text, type, options) {
		// set default options
		var text    = (typeof(text) != 'undefined') ? text : 'Loading...';
		var type    = (typeof(type) != 'undefined') ? type : 'notice';
		var options = (typeof(options) != 'undefined') ? options : {};
		if (typeof(options['stay']) == 'undefined')
			options['stay'] = true;
		
		if (statusCount == 0)
			jQuery.noticeAdd(jQuery.extend(options, {text: text, type: type}));
		
		if (options['stay'] == true)	
			statusCount++;
		console.log("StatusCount: " + statusCount);
	}

	/* public methods */	
	return {
		loading: function() {
			show('Loading...', 'notice');
		},
		
		notify: function(text) {
			show(text, 'notice', {stay: false});
		},
		
		error: function(text) {
			show(text, 'notice', {type: 'error'});
		},
		
		hide: function() {
			if (statusCount == 1)
				jQuery.noticeRemove($('.notice-item-wrapper'));
			statusCount--;
			console.log("StatusCount: " + statusCount);
		},
		
		hideAll: function() {
			jQuery.noticeRemove($('.notice-item-wrapper'));
			statusCount = 0;
		}
	}
}();


// Usage: IFrame.resizeAll()
IFrame = function() {
	var resize = function(iframe) {
		// only resize if iframe is visible
		if (iframe.style.display != 'none') {
			var innerDoc = iframe.contentDocument ? iframe.contentDocument : iframe.contentWindow.document;
			iframe.height = innerDoc.body.scrollHeight;
		}
	}
	
	return {
		resizeAll: function() {
			$('iframe').each(function(index, iframe) {
				resize(iframe);
			})
		}
	}
}();


// Prepare callbacks for a template (preview) which get triggered after an iframe is loaded
// Usage example: Callback.prepare(1, function() { alert('yo') })
//                Callback.trigger(1)
Callback = function() {
	var callbacks = {};

	return {
		prepare: function(id, func) {
			callbacks[id] = func;
		},
		
		trigger: function(id) {
			if (typeof(callbacks[id]) != 'undefined' && callbacks[id]) {
				console.log("Running callback for template #" + id);
				callbacks[id].call();
				callbacks[id] = null;
			}
		}
	}
}();