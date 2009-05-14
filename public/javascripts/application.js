Debug = function() {
	// set to true to print all important javascript debug messages
	// set to false to skip all debug messages (for production)
	var debug = true;
	
	return {
		log: function(text) {
			if (debug) { console.log(text); }
		}
	}
}();


Templates = function() {
	var _order     = null;
	var _templates = null;
	var editmode  = false;
	
	/* private methods */
	var togglePrintButton = function() {
	  if (_templates.length > 0) {
			$("#print-start").hide();
	    $("#print-button").show();
			var pluralize = _templates.length == 1 ? "document" : "documents"
			$("#template-amount").html(_templates.length + " " + pluralize)

	  } else {
	    $("#print-button").hide();
			$("#print-start").show();
	  }
	}

	var toggleInlinePreview = function(template) {
		// preview iframe, could be already inserted (cached in DOM)
		var templatePreview = $("#inline-preview-" + template);
		var templateLabel = $("#template-item-" + template + " label");
		// is template selected?
		if (_templates.indexOf(template) > -1) {
			templateLabel.addClass("selected");
			if (templatePreview.length > 0) { 
	      templatePreview.show();
	    } else {
				loadInlinePreview(template);
			}			
		} else {
			templateLabel.removeClass("selected");
			templatePreview.hide();
		}
	}
	
	var loadInlinePreview = function(template) {
		var checkbox = $("#template-item-" + template + " :checkbox").disable();
		// this is a dirty fix, because the link doesn't listen to moveout-events any more, so it doesn't get hidden, which looks weird
		$("#template-delete-link-" + template).hide();
		
		Status.show("Loading preview...");
		$("#preview-" + template).load("/orders/" + _order + "?template_id=" + template, null, function() { checkbox.enable(); Status.hide(); });
	}

	var templateChanged = function(template) {
		togglePrintButton();
		toggleInlinePreview(template);
		Debug.log("Template #" + template + " has changed.")
	}

	
	/* public methods */
	return {
		initialize: function(order) {
			_order = order;
			_templates = [];
		},
		
		select: function(template, selection) {
			var checkbox = $('#template-item-' + template + " :checkbox");
			checkbox.attr('checked', selection)
			this.updateSelection(checkbox);
		},
		
		updateSelection: function(checkbox) {
			var template = checkbox.val();
			Debug.log("Updating selection for template-checkbox-" + template + "...");
			if (checkbox.attr('checked') == true) {
				Debug.log("Checkbox selected");
				if (_templates.indexOf(template) == -1)
					_templates.push(template);
			} else {
				Debug.log("Checkbox deselected");
				_templates.splice(_templates.indexOf(template), 1);
			}

			templateChanged(template);
		},
	
		print: function() {
			$.ajax({
	      url: 	'/orders/' + _order + '/print',
				data: $("#selected-templates").serialize(),
	      type: 'post'
	    });
			window.print();
		},
		
		toggleEditMode: function() {
			editmode = !editmode;
			$(".template-options").toggle();
			$(".new-template").toggle();
			
			if (editmode) {
				var editmodeLabel = "Stop editing";		
			} else {
				var editmodeLabel = "Edit templates";
			}
			$(".template-editmode a").html(editmodeLabel);
		}
	}
}();


// Usage: Dialog.open() and Dialog.close()
// Opens a div as a modal dialog which you need to fill yourself first
Dialog = function() {
	var dlg = "#modal-dialog";

	var options = function(otherOptions) {
		var dialogOptions = {
	  	modal: true
		};
		
		dialogOptions = jQuery.extend(dialogOptions, otherOptions, screenDimensions());
		return dialogOptions;
	}

  var screenDimensions = function() {
		content = $('#modal-dialog')[0];
		var viewportwidth;
		var viewportheight;

		// the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
 		if (typeof window.innerWidth != 'undefined') {
	  	viewportwidth = window.innerWidth,
			viewportheight = window.innerHeight
		} else if (typeof document.documentElement != 'undefined'	&& typeof document.documentElement.clientWidth !=
	     'undefined' && document.documentElement.clientWidth != 0) {
			// IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
      viewportwidth = document.documentElement.clientWidth,
		  viewportheight = document.documentElement.clientHeight
		} else {
			// older versions of IE
      viewportwidth = $('body')[0].clientWidth,
      viewportheight = $('body')[0].clientHeight
    }
		
		// open dialog with -20% of maximal screen height and fixed letter width
    var y = viewportheight - (viewportheight/10) * 2;
    var x = '8.5in';

    return { width: x, height: y };
  }

	return {                      
		
		
		open: function(title, otherOptions) {
		  
		  var resizeMethod = function(event,ui) {
		    var elementsPx = 0;
		    $(event.target).children('.fixed').each(function(e){
		      elementsPx += e.height();
		    })
		    
		    $(event.target).select('textarea').height(dialogHeight - elementsPx - 20 /*margin*/)		    
		  );
		  
			var otherOptions = (typeof(otherOptions) != 'undefined') ? otherOptions : {};
			var opts = options(otherOptions);
			$(dlg).dialog(jQuery.extend(opts, {title: title }));
			$(dlg).dialog('open')
			$(dlg).bind("resize", f8);
			$(dlg).trigger("resize");
		},
		
		close: function() {
			$(dlg).empty();
			$(dlg).dialog('destroy');
		}
	}
}();


// Shopify Javascript Messenger
/*-------------------- Messenger Functions ------------------------------*/
// Messenger is used to manage error messages and notices
//
Messenger = function() {
	var autohide_error  = null;
  var autohide_notice = null;
	
	// Responsible for fading notices level messages in the dom    
  var fadeNotice = function() {
    $('#flashnotice').fadeOut();
    autohide_notice = null;
  };
  
  // Responsible for fading error messages in the DOM
  var fadeError = function() {
    $('#flasherrors').fadeOut();
    autohide_error = null;
  };
  
	return {
		// Notice-level messages.  See Messenger.error for full details.
	  notice: function(message) {
	    $('#flashnotice').html(message);
	    $('#flashnotice').fadeIn()

	    if (autohide_notice != null) { clearTimeout(autohide_notice); }
	    autohide_notice = setTimeout(fadeNotice, 5000);
	  },		
	  
	  // When given an error message show it on the screen. 
	  // This message will auto-hide after a specified amount of miliseconds
	  error: function(message) {
	    $('#flasherrors').html(message);
	    $('#flasherrors').fadeIn()

	    if (autohide_error != null) { clearTimeout(autohide_error); }
	    autohide_error = setTimeout(fadeError, 5000);
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
			Debug.log("Called Status.show, count is now: " + count)
		},

		hide: function() {
			if (count <= 1) { notice.fadeOut(); count = 1 }
			count--;
			Debug.log("Called Status.hide, count is now: " + count)
		},
		
		reset: function() {
			count = 0
		}
		
	}
}();


// Usage: IFrame.resizeAll()
// Resizes iframe to automatically fit it's content
IFrame = function() {
	var resize = function(iframe) {
		// only resize if iframe is visible
		if (iframe.style.display != 'none') {
			//Debug.log("Resizing visible iFrame " + iframe.id)
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
				Debug.log("Running callback for template #" + id);
				callbacks[id].call();
				callbacks[id] = null;
			}
		}
	}
}();