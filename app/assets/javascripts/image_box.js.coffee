#= require utils
#= require selectable

unless window.image_box
  window.image_box = {}

  class window.image_box.ImageBox extends window.sel.Deleteable
    
    constructor: (@image_tag, @container, @grid_size) ->
      
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
          grid: [@grid_size, @grid_size]
          containment: @container
          cancel: ".do_not_drag"
          drag: @drag_handler

        @element.resizable
          grid:[@grid_size, @grid_size]
          resize: @resize_handler
          handles: window.controls.add_resize_handles_to_selectable this
          containment: @container

    
    drag_handler: (event, ui) =>
      window.utils.delay =>
        if ui.position.left != @prev_location.left or ui.position.top != @prev_location.top
          @element.trigger "modified"
          console.log "why does logging this make it go faster?"
        @prev_location = ui.position
    
    resize_handler: =>
      window.utils.delay =>
        if @element.width() != @prev_size.width or @element.height() != @prev_size.height
          @element.trigger "modified"
        @prev_size =
          width: @element.width()
          height: @element.height()
        new_aspect_ratio = @element.width()/@element.height()
        if new_aspect_ratio > @aspectRatio
          @image_tag.height(@element.height())
          @image_tag.width(@image_tag.height()*@aspectRatio)
        else
          @image_tag.width(@element.width())
          @image_tag.height(@image_tag.width()/@aspectRatio)
