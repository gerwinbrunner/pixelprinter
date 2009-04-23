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
		// this is a dirty fix, because the link doesn't listen to moveout-events any more, so it doesn't get hidden, which looks weird
		$("#template-delete-link-" + template).hide();
		
		Status.show();

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
	      beforeSend: function(request) { Status.show(); }, 
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


// Usage: Dialog.open() and Dialog.close()
// Opens a div as a modal dialog which you need to fill yourself first
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
//			$(dlg).html('');
		}
	}
}();


// Status.show() shows a permanent Growl-like notification.
// Repeating calls to show() will leave the same first notification open.
// Status.hide() closes it again. Make sure to call hide() for EACH time you call show()!
Status = function() {
	var count = 0;
	
	return {
		show: function(text) {
			// don't show more than one notice at a time
			if (count < 1) {
				var text = (typeof(text) != 'undefined') ? text : 'Loading...';
				$("#notice-item p").html(text);
				notice = $("#notice-item-wrapper");
				notice.fadeIn();
			
				if(navigator.userAgent.match(/MSIE 6/i)) {
			  	notice.css({top: document.documentElement.scrollTop});
			  }
			}
			count++;
			console.log("Called show, count is now: " + count)
		},

		hide: function() {
			if (count == 1) { notice.fadeOut(); }
			count--;
			console.log("Called hide, count is now: " + count)
		}
	}
}();


// Usage: IFrame.resizeAll()
// Resizes iframe to automatically fit it's content
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


// Shopify Javascript Messenger
/*-------------------- Messenger Functions ------------------------------*/
// Messenger is used to manage error messages and notices
//
Messenger = function() {
	var effect = 'slide';
	var effectOptions = {direction: 'down'};
  
	var autohide_error  = null;
  var autohide_notice = null;
	
	// Responsible for fading notices level messages in the dom    
  var fadeNotice = function() {
    $('#flashnotice').hide(effect, effectOptions);
    autohide_notice = null;
  };
  
  // Responsible for fading error messages in the DOM
  var fadeError = function() {
    $('#flasherrors').hide(effect, effectOptions);
    autohide_error = null;
  };
  
	return {
		// Notice-level messages.  See Messenger.error for full details.
	  notice: function(message) {
	    $('#flashnotice').html(message);
	    $('#flashnotice').show(effect, effectOptions);

	    if (autohide_notice != null) { clearTimeout(autohide_notice); }
	    autohide_notice = setTimeout(fadeNotice, 5000);
	  },		
	  
	  // When given an error message show it on the screen. 
	  // This message will auto-hide after a specified amount of miliseconds
	  error: function(message) {
	    $('#flasherrors').html(message);
	    $('#flasherrors').show(effect, effectOptions);

	    if (autohide_error != null) { clearTimeout(autohide_error); }
	    autohide_error = setTimeout(fadeError, 5000);
	  }
	}  
}();