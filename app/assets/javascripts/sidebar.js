

$(function(){
  $("#add_rectangle").click(function(){

    //later run a variable check:
    //if drawer == closed, open up the "image upload" dialog
      //after image URL is entered and image is uploaded, display drawer
    //if drawer == open, open up "image upload" dialog
      //after image URL is entered and image is uploaded, add image thumbnail to already-open drawer
    //drawer "closes" if image queue/marquee is now empty
    //drawer stays "open" if image queue/marquee is not empty
    //toggleSlide(this);
    $('#imageUploadDialog').dialog({
      autoOpen:false,
      height: 200,
      width: 350,
      modal: true,
      buttons: {
        "Attach Image": function(){
          var validURL = true;
          allFields.removeClass("ui-state-error");

        },
        Cancel: function(){
          $(this).dialog("close");
        }
      },
      close: function(){
        allFields.val("").removeClass("ui-state-error");
      }
    });

    openDialog($("#add_rectangle"));
    toggleSlide($("#add_rectangle"));
  });
});

function toggleSlide(element){
  if ($("#imageDrawerContent").is(":hidden")){
    element.addClass('drawerOpen');
    $("#imageDrawerContent").slideDown();
  }
  else{
    $("#imageDrawerContent").slideUp();
    element.removeClass('drawerOpen');
  }
};

function addToMarquee(image, marquee){
}

function removeFromMarquee(image, marquee){
}

function openDialog(element){
  $("#imageUploadDialog").dialog('open');
}


