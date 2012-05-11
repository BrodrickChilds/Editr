var place_cursor = function(el) {
	el = $(el);
	var range = document.createRange();
	var sel = window.getSelection();
	var index = el.text().indexOf('$cursorhere$');
	range.setStart(el.get(0).childNodes[0], index );
	range.setEnd(el.get(0).childNodes[0], index + 12 );
	event_on = false;
	range.deleteContents();
	range.collapse(true);
	sel.removeAllRanges();
	sel.addRange(range);
	event_on = true;
}

var getSelected = function(){
	var t = '';
	if(window.getSelection){
		t = window.getSelection();
	}else if(document.getSelection){
		t = document.getSelection();
	}else if(document.selection){
		t = document.selection.createRange().text;
	}
	return t;
}

var getStyles = function(){
	var styles = {bold:false, italic:false};
	if(!$(window.getSelection().anchorNode).attr('contenteditable')){
		var node = window.getSelection().anchorNode.parentNode;
		while(!$(node).attr('contenteditable')){
			if ($(node).css('fontWeight') == 700 || $(node).css('fontWeight') == 'bold' || node.nodeName == "B"){
				styles.bold = true;
			}
			if ($(node).css('fontStyle') == 'italic' || node.nodeName == "I"){
				styles.italic = true;
			}
			node = node.parentNode;
		}
	}
	return styles;
}

var insertStyle = function(element){
	if (window.getSelection) {  // all browsers, except IE before version 9
		var selection = window.getSelection ();
		if (selection.rangeCount > 0) {
			var range = selection.getRangeAt (0);
			range.insertNode(element);
			range.collapse(false);
			element.startSelection = 0;
			element.focus();
		}
	}
}

var attachEvents = function(element){
	element.click(function(e){
		curFocus = window.getSelection();
		var styles = getStyles();
		if(styles.bold){
			$("#toolbar_bold").removeClass('unpressed').addClass('pressed');
		}
		else{
			$("#toolbar_bold").removeClass('pressed').addClass('unpressed');
		}
		if(styles.italic){
			$("#toolbar_italic").removeClass('unpressed').addClass('pressed');
		}
		else{
			$("#toolbar_italic").removeClass('pressed').addClass('unpressed');
		}
	});
}

var switchBorder = function(e){
	if(e.hasClass('unpressed')){
		e.removeClass('unpressed').addClass('pressed');
	}
	else{
		e.removeClass('pressed').addClass('unpressed');
	}
}
$( function(){
	
	$("#toolbar_bold").click(function(event){
		var selected = getSelected();
		if(selected == ""){
			var boldNode = document.createElement('b');
			insertStyle(boldNode);
			$(boldNode).append("$cursorhere$" );
			place_cursor(boldNode);
			switchBorder($("#toolbar_bold"));
		} else {
			document.execCommand('bold',false,null);
			switchBorder($("#toolbar_bold"));
		}
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();
	});
	$("#toolbar_italic").click(function(event){
		var selected = getSelected();
		
		if(selected == ""){
			var italicNode = document.createElement('i');
			insertStyle(italicNode);
			$(italicNode).append("$cursorhere$" );
			place_cursor(italicNode);
			switchBorder($("#toolbar_italic"));
		} else {
			document.execCommand('italic',false,null);
			switchBorder($("#toolbar_italic"));
		}
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();
	});
	$("#toolbar_alignment").click(function(event){
		var selected = getSelected();
		
		if(selected == ""){
			
		} else {
			
		}
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();
	});
	$("#floatingbar").click(function(event){
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();
	});
		
});
