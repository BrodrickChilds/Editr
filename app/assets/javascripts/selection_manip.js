

var os_insert_placeholder = function(){
  var text = "$$$";    

  console.log(window.text.wrapping_texts);

  var sel, range, html;
  if (window.getSelection) {
      sel = window.getSelection();
      if (sel.getRangeAt && sel.rangeCount) {
          range = sel.getRangeAt(0);
          range.deleteContents();
          range.insertNode( document.createTextNode(text) );
      }
  } else if (document.selection && document.selection.createRange) {
      document.selection.createRange().text = text;
  }
}

var os_place_cursor = function() {
  var el = $("body").find(".structural:contains('$$$')");

  var range = document.createRange();
  var sel = window.getSelection();
  var index = el.text().indexOf('$$$');

  console.log(index);

  range.setStart(el.get(0).childNodes[0], index );
  range.setEnd(el.get(0).childNodes[0], index + 3 );
  range.deleteContents();
  range.setStart(el.get(0).childNodes[0], index+1 );
  range.setEnd(el.get(0).childNodes[0], index+1 );
  range.collapse(true);
  sel.removeAllRanges();
  sel.addRange(range); 
}
