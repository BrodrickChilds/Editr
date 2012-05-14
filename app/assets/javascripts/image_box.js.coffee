#= require utils
#= require selectable

unless window.image_box
  window.image_box = {}

  window.image_box.list = []

  class window.image_box.ImageBox extends window.sel.Deleteable
    
    constructor: (@image_tag, @container, @grid_size) ->
     
      window.image_box.list.push(this)

      @element = $ "<div></div>"
      @element.addClass "image_box"
      @element.css
        width: grid_size*10 - 4 #2 for border width
        height: grid_size*7 - 4
        top: 0
        left: 0 
 
      super(@element)
      
      @container.append @element 
      
      @element.append @image_tag

      console.log @image_tag

      window.utils.delay =>
        @origWidth = @image_tag.width()
        @origHeight = @image_tag.height()
        @aspectRatio = @origWidth / @origHeight
 
        @prev_size =
          width: -1
          height: -1
        
        @resize_handler()

        @prev_location =
          left: -1
          top: -1

        @element.draggable
          grid: [@grid_size/2, @grid_size/2]
          containment: @container
          cancel: ".do_not_drag"
          stop: @drag_handler
          stack: "#page_content div"

        @element.resizable
          grid:[@grid_size/2, @grid_size/2]
          resize: @resize_handler
          stop: @resize_stop
          handles: window.controls.add_resize_handles_to_selectable this
          containment: @container

    
    drag_handler: (event, ui) =>
      window.utils.delay =>
        if ui.position.left != @prev_location.left or ui.position.top != @prev_location.top
          @element.trigger "modified"
          console.log "why does logging this make it go faster?"
        @prev_location = ui.position
   
    resize_stop: =>
      window.utils.delay =>
        if @element.width() != @prev_size.width or @element.height() != @prev_size.height
          @element.trigger "modified"
        @prev_size =
          width: @element.width()
          height: @element.height()

    resize_handler: =>
      window.utils.delay =>
        new_aspect_ratio = @element.width()/@element.height()
        if new_aspect_ratio > @aspectRatio
          @image_tag.height(@element.height())
          @image_tag.width(@image_tag.height()*@aspectRatio)
        else
          @image_tag.width(@element.width())
          @image_tag.height(@image_tag.width()/@aspectRatio)

    delete: =>
      window.image_box.list = (box for box in window.image_box.list when box isnt this)
      @element.trigger "modified"
      super()
