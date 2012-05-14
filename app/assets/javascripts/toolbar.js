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

var getStylesAt = function(node, index){
  var range = document.createRange();
  var nodeIndex = 0;
  
  var insert = document.createElement('bladasdfsdfnk');
  range.insertNode(insert);
}

var treeRecurse = function(node, curOffset, maxOffset){
  var info = [node, curOffset, maxOffset];
  if (curOffset >= maxOffset){
    return info;
  }
  if (node.childNodes.length == 0){
    
  }
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

var addSelectionStyle = function(style){
  var node = {};
  if(style == "bold"){
    node = document.createElement('b');
  }
  else if(style == "italic"){
    node = document.createElement('i');
  }
  var selected = getSelected();
  if(selected == ""){
    insertStyle(node);
    $(node).append("$cursorhere$");
    place_cursor(node);
  } else {
    document.execCommand(style,false,null);
  }
  $(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
  return node;
}

var removeSelectionStyle = function(styles){
  var node = window.getSelection().anchorNode.parentNode;
  var range = window.getSelection().getRangeAt(0);
  if(!$(window.getSelection().anchorNode).attr('contenteditable')){
		while(!$(node.parentNode).attr('contenteditable')){
      node = node.parentNode;
    }
  }
  var contentEditableNode = node.parentNode;
  var styleList = [];
  for (style in styles){
    if(styles[style]){
      styleList.push(style);
    }
  }
  if(styleList.length == 0){
    styleList.push('blank');
  }
  splitRange(contentEditableNode, 5);
  //var range = document.createRange();
	//range.setStartAfter(node);
  //range.setEndAfter(node);
  var innerNode = {};
  for(var i = 0; i<styleList.length; i++){
    var newNode = makeStyleNode(styleList[i]);
    if(i == 0){
      innerNode = newNode;
      $(newNode).append("$cursorhere$");
      range.insertNode(newNode);  
      range.setEndAfter(newNode);
    }
    else{
      range.surroundContents(newNode);
    }
  }
  place_cursor(innerNode);
  event_on = true;
}

var splitRange = function(node, index){
  var entireRange = document.createRange();
  var leftRange = document.createRange();
  var rightRange = document.createRange();
  entireRange.selectNodeContents(node);
  getStylesAt(node, 1);
}

var makeStyleNode = function(style){
  var node = {};
  if(style == "bold"){
    node = document.createElement('b');
  }
  else if(style == "italic"){
    node = document.createElement('i');
  }
  else if(style == "blank"){
    node = document.createElement('blank');
  }
  return node;
}

$( function(){
	
	$("#toolbar_bold").click(function(event){
		var selected = getSelected();
    var curStyles = getStyles();
    if(selected == "" && curStyles.bold){
      curStyles.bold = false;
      removeSelectionStyle(curStyles);
    }
    else{
      addSelectionStyle('bold');
    }
    switchBorder($("#toolbar_bold"));
	});
	$("#toolbar_italic").click(function(event){
		var selected = getSelected();
    var curStyles = getStyles();
    if(selected == "" && curStyles.italic){
      curStyles.italic = false;
      removeSelectionStyle(curStyles);
    }
    else{
      addSelectionStyle('italic');
    }
    switchBorder($("#toolbar_italic"));
	});
	$("#toolbar_alignment").click(function(event){
		/*var selected = getSelected();
		
		if(selected == ""){
			
		} else {
			
		}
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();*/
	});
	$("#floatingbar").click(function(event){
		$(window.getSelection().anchorNode).parents("[contenteditable='true']").focus();
		event.stopPropagation();
	});
		
});
