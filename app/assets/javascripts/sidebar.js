//= require editor

$(function(){

  $("#add_rectangle").click(function(){
    var imageURL = $("#URLinput");
 
    $("#imageUploadDialog").dialog({
      autoOpen:false,
      height: 200,
      resizable: false,
      width: 450,
      modal: true,
      title: "+ New Image",
      buttons: {
        "Attach Image": function(){

          var validURL = true;
          validURL = validURL && checkURL(imageURL, /\.(jpg|png|gif)$/i);
          if (validURL){
            addToMarquee(imageURL.val());
            $(this).dialog("close");
            $("#URLinput").val("");
            $("#imageURLWarn").css("display","none");
          }
        },
        Cancel: function(){
          $(this).dialog("close");
          $("#URLinput").val("");
          $("#imageURLWarn").css("display","none");
        }
      },
      close: function(){
        $("#URLinput").val("");
        $("#imageURLWarn").css("display","none");
      }
    });

    openDialog();
  });


  $(document).click(function(e){
    if (e.target.tagName.toLowerCase() == "img"){
      if ($(e.target).is("#imageDrawerContent *")){
        window.images.insert_image($(e.target).attr("src"));
        removeFromMarquee($(e.target));
      }
    } 
  });

  

});

function openDrawer(){
  if ($("#imageDrawerContent").is(":hidden")){
    $("#add_rectangle").addClass("drawerOpen");
    $("#imageDrawerContent").slideDown();
  }
}

function closeDrawer(){
  if (!$("#imageDrawerContent").is(":hidden")){
    $("#imageDrawerContent").slideUp();
    $("#add_rectangle").removeClass("drawerOpen");
  }
}

function addToMarquee(imageURL){
  openDrawer();
  var content = document.getElementById("imageDrawerContent");

  var newSpan = document.createElement("span");

  var newDiv = document.createElement("div");
  newDiv.className = "thumbnailDiv";

  var img = document.createElement("IMG");
  img.src = imageURL;

  content.appendChild(newSpan);
  newSpan.appendChild(newDiv);
  newDiv.appendChild(img);

  img.className = "thumbnail";

  set_dimensions = function(){
  if ($(img).width() >= $(img).height()){
    img.style.width = '90%';
    img.style.height = 'auto';
  }else{
    img.style.height = '90%';
    img.style.width = 'auto';
  }
  }

  if($(img).width() != 0){
    set_dimensions();
  } else {
    $(img).load(set_dimensions);
  }

  content.scrollTop = content.scrollHeight;
}

function removeFromMarquee(image){
  var parentDiv = $(image).parent();
  var parentSpan = $(parentDiv).parent();
  var parent = $(parentSpan).parent();

  $(parentSpan).remove();
  if (!($("#imageDrawerContent").children().length>0)){
    closeDrawer();
  }
}

function openDialog(){
  $("#imageUploadDialog").dialog('open');
}

function checkURL(o, regexp){
  if (o.length == 0){
    return false;
  }
  if(!(regexp.test(o.val()))){
    $("#imageURLWarn").css("display","inline");
    return false;
  }else{
    $("#imageURLWarn").css("display","none");
    return true;
  }
}

