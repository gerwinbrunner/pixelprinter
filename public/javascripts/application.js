Debug = function() {
	// set to true to print all important javascript debug messages
	// set to false to skip all debug messages (for production and browsers without Firebug)
	var debug = false;
	
	return {
		log: function(text) {
			if (debug) { console.log(text); }
		}
	};
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
			var pluralize = _templates.length == 1 ? "document" : "documents";
			$("#template-amount").html(_templates.length + " " + pluralize);
	  } else {
	    $("#print-button").hide();
			$("#print-start").show();
	  }
	};

	var toggleInlinePreview = function(template) {
		// preview div, which could be already inserted (cached in DOM)
		var templatePreview = $("#inline-preview-" + template);
		var templateLabel = $("#template-item-" + template + " label");
		// is template selected?
		if (_templates.indexOf(template) > -1) {
			templateLabel.addClass("selected");
			if (templatePreview.length > 0) { 
	      templatePreview.fadeIn();
				scrollToPreview(template);
	    } else {
				loadInlinePreview(template);
			}			
		} else {
			templateLabel.removeClass("selected");
			templatePreview.hide();
			
		}
	};
	
	var loadInlinePreview = function(template) {
		var checkbox = $("#template-item-" + template + " :checkbox").disable();
		// this is a dirty fix, because the link doesn't listen to moveout-events any more, so it doesn't get hidden, which looks weird
		$("#template-delete-link-" + template).hide();
		
		Status.show("Loading preview...");
		$.get("/orders/" + _order + "?template_id=" + template, null, function(data) { checkbox.enable(); Status.hide(); $("#preview-" + template).html(data); scrollToPreview(template)});
	};

	var scrollToPreview = function(id) {
		var targetOffset = $("#preview-" + id + " .preview-content").offset().top;
	  $('html,body').animate({scrollTop: targetOffset - 40}, 500);
	};
	
	
	/* public methods */
	return {
		initialize: function(order) {
			_order = order;
			_templates = [];
		},
		
		checkAll: function() {
		  $("#selected-templates :checkbox").each(function() { 
				Templates.updateSelection($(this));
			});	
		},
		
		updateSelection: function(checkbox) {
			var template = checkbox.val();
			if (checkbox.attr('checked')) {
				Debug.log("template-checkbox-" + template + " selected.");
				if (_templates.indexOf(template) == -1) {
					_templates.push(template);
				}
			} else {
				Debug.log("template-checkbox-" + template + " deselected.");
				var position = _templates.indexOf(template);
				if (position > -1) { _templates.splice(position, 1); }
			}
			togglePrintButton();
			toggleInlinePreview(template);
		},
		
		print: function() {
			$.ajax({
	      url: 	'/orders/' + _order + '/print',
				data: $("#selected-templates").serialize(),
	      type: 'post'
	    });
			window.print();
		},

		select: function(template, selection) {
			var checkbox = $('#template-item-' + template + " :checkbox");
			checkbox.attr('checked', selection);
			Templates.updateSelection(checkbox);
		},
		
		toggleEditMode: function() {
			editmode = !editmode;
			// disable animations for Internet Explorer < 8
			if(navigator.userAgent.match(/MSIE (5|6|7)/i)) {
				$(".template-options").toggle();
				$(".new-template").toggle();
			} else {
				$(".template-options").toggle(350);
				$(".new-template").slideToggle();
			}
			var linkImage = $(".template-editmode a img");
			
			if (editmode) {
				linkImage.data("old-image", linkImage.attr('src')); /* Remember original link image */
				linkImage.data("old-title", linkImage.attr('title'));
				linkImage.attr('src', '/images/button-done.png');
				linkImage.attr('title', 'Done with editing templates');
			} else {
				linkImage.attr("src", linkImage.data("old-image"));   /* Restore original link image */
				linkImage.attr("title", linkImage.data("old-title"));   /* Restore original link image */
			}
		}
	};
}();


// Usage: Dialog.open() and Dialog.close()
// Opens a div as a modal dialog which you need to fill yourself first
Dialog = function() {
	var dlg     = "#modal-dialog";
	var options = {modal: true};
	
	var percent = function(amount, percentage) {
		return (amount / 100) * percentage;
	};
 
	var	resizeTextArea = function() {
		var dialogHeight = parseInt($(dlg).height());
		var elementsHeight = 0;
   	$(dlg + " .fixed").each(function(index, elem){
			var height = parseInt($(elem).height());
      elementsHeight += height;
    });

		var heightModifier = 60;
		
		var textAreaHeight = dialogHeight - elementsHeight - heightModifier; /*margin*/
		
		Debug.log("DialogHeight: " + dialogHeight + "\nElementsHeight: " + elementsHeight + "\nTextAreaHeight: " + textAreaHeight);
    $("#template_editor").height(textAreaHeight);   
	};

	return {                      
		open: function(title) {
		  var width  = $(window).width();
		  var height = $(window).height();
		
			// open with 80% width and height
			$(dlg).dialog(jQuery.extend(options, {width: percent(width, 80), height: percent(height, 80)}, {title: title, resize: resizeTextArea, open: resizeTextArea}));
			$(dlg).dialog('open');//.bind("dialogopen resize", resizeTextArea);
		},
		
		close: function() {
			$(dlg).empty();
			$(dlg).dialog('close');
		}	
	};
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
	    $('#flashnotice').fadeIn();

	    if (autohide_notice != null) { clearTimeout(autohide_notice); }
	    autohide_notice = setTimeout(fadeNotice, 5000);
	  },		
	  
	  // When given an error message show it on the screen. 
	  // This message will auto-hide after a specified amount of miliseconds
	  error: function(message) {
	    $('#flasherrors').html(message);
	    $('#flasherrors').fadeIn();

	    if (autohide_error != null) { clearTimeout(autohide_error); }
	    autohide_error = setTimeout(fadeError, 5000);
	  }
	};
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
				text = (typeof(text) != 'undefined') ? text : 'Loading...';
				$("#notice-item p").html(text);
				notice = $("#notice-item-wrapper");
				notice.fadeIn();
			
				if(navigator.userAgent.match(/MSIE 6/i)) {
			  	notice.css({top: document.documentElement.scrollTop});
			  }
			}
			count++;
			Debug.log("Called Status.show, count is now: " + count);
		},

		hide: function() {
			if (count <= 1) { 
				notice.fadeOut();
				count = 1;
			}
			count--;
			Debug.log("Called Status.hide, count is now: " + count);
		},
		
		reset: function() {
			count = 0;
		}
		
	};
}();