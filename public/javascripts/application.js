Templates = function() {
	var _order = null;
	var _templates = null;
	
	/* private methods */
	var togglePrintButton = function() {
		var selected = $("#selected-templates :checkbox:checked").length;
	  if (selected > 0) {
	    $("#print-button").show();
	  } else {
	    $("#print-button").hide();
	  }
	}

	var toggleInlinePreview = function(template) {
		// preview div with iframe, could be already inserted (cached in DOM)
		var templatePreview = $("#template-preview-" + template);
		// is templates selected?
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
		var iframeID = "iframe-preview-" + template;
		var preview = "<div id='template-preview-" + template + "'> \
			<div class='template-preview'> \
				<iframe src='" + url + "' id='" + iframeID + "' onload='Callback.trigger(" + template +")' scrolling='no' width='100%' frameborder='0' ></iframe> \
			</div> \
		</div>";
	  $("#preview-" + template).html(preview);
	}
	
	/* public methods */
	return {
		initialize: function(order) {
			_order = order;
			_templates = [];
		},
		
		update: function(template) {
			togglePrintButton();
			toggleInlinePreview(template);
		},

		updateSelection: function(checkbox) {
			var template = checkbox.val();

			if (checkbox.attr('checked') == true) {
				_templates.push(template);
			} else {
				_templates.splice(_templates.indexOf(template), 1);
			}

			this.update(template);
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
		// pretty hacky (i.e. unclean: extract template id from the iframe-id)
		var id = iframe.id.match(/\d+/)[0];
		var envelope = $("#template-preview-" + id);
		// only resize if iframe (packed in div envelope) is visible
		if (envelope.css('display') != 'none') {
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