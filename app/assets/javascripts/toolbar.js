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
			$("#toolbar_bold").css('border-style',  'inset');
		}
		else{
			$("#toolbar_bold").css('border-style',  'none');
		}
		if(styles.italic){
			$("#toolbar_italic").css('border-style',  'inset');
		}
		else{
			$("#toolbar_italic").css('border-style',  'none');
		}
	});
}

var switchBorder = function(e){
	if(e.css('border-bottom-style') == 'inset'){
		e.css('border-style', 'none');
	}
	else{
		e.css('border-style', 'inset');
	}
}
$( function(){
	
	$("#toolbar_bold").click(function(event){
		var selected = getSelected();
		if(selected == ""){
			var boldNode = document.createElement('b');
			insertStyle(boldNode);
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
