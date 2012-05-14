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

var getNodeAt = function(node, index){
  var range = document.createRange();
  var nodeIndex = 0;
  var info = [node, 0, index, 0];
  var newInfo = treeRecurse(node, info);
  if(newInfo[0] == node){ //Nothing happened.
    return [node, 0];
  }
  else{
    newInfo = [newInfo[0], newInfo[3]];
    return newInfo;
  }
}

var treeRecurse = function(node, info){
  curOffset = info[1];
  maxOffset = info[2];
  if (curOffset >= maxOffset){
    return info;
  }
  if(node.nodeType == 3){
    if(curOffset + node.length > maxOffset){
      info[3] = maxOffset - curOffset;
      info[0] = node;
    }
    info[1] += node.length;
    return info;
  }
  else{
    var newInfo = info;
    for(var i = 0; i < node.childNodes.length; i++){
      console.log(newInfo);
      newInfo = treeRecurse(node.childNodes[i], newInfo);
      if (newInfo[1]>=newInfo[2]){
        break;
      }
    }
    return newInfo;
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
    styleList.push('span');
  }
  var insertLoc = splitRange(contentEditableNode, 5);
  var range = document.createRange();
	range.setStartAfter(insertLoc[0][0]);
  range.setEndBefore(insertLoc[1][0]);
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
  var nodeOffset = getNodeAt(node, 6);
  var contentNode = nodeOffset[0];
  entireRange.selectNodeContents(contentNode);
  leftRange.setStart(contentNode, 0);
  leftRange.setEnd(contentNode, nodeOffset[1]);
  rightRange.setStart(contentNode, nodeOffset[1]);
  rightRange.setEndAfter(contentNode);
  var leftInner = document.createElement('span');
  var rightInner = document.createElement('span');
  $(leftInner).text(leftRange.toString());
  $(rightInner).text(rightRange.toString());
  leftRange.selectNodeContents(leftInner);
  rightRange.selectNodeContents(rightInner);
  var leftClone;
  var rightClone;
  while(!$(contentNode.parentNode).attr('contenteditable')){
    contentNode = contentNode.parentNode;
    rightClone = contentNode.cloneNode(false);
    leftClone = contentNode.cloneNode(false);
    leftRange.surroundContents(leftClone);
    rightRange.surroundContents(rightClone);
  }
  deleteNode = entireRange.startContainer;
  while(!$(deleteNode.parentNode).attr('contenteditable')){
    deleteNode = deleteNode.parentNode;
  }
  $(deleteNode).empty();
  $(leftClone).insertAfter($(deleteNode));
  $(rightClone).insertAfter($(leftClone));
  $(deleteNode).remove();
  var insertLoc = [$(leftClone), $(rightClone)];
  return insertLoc;
  
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
