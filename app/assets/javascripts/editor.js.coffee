#= require selectable

num_cols = 24
margin = 5

get_grid_canvas = -> $("#grid")
get_borders_canvas = -> $("#borders")
get_page_content = -> $("#page_content")

delay = (func) ->
  setTimeout func, 50

add_drag_handle = (element) ->
  button = $ "<div></div>"
  button.text "drag to reorder"
  button.addClass "handle text-drag-handle"
  element.append button

  button.hide()

  element.mouseover -> button.show()
  element.mouseout -> button.hide()

  return button

add_resize_handles = (element) ->
  jquery_ui_args = {}

  for name in ["n", "s", "e", "w", "se", "sw", "nw"]
    
    handle = $("<div></div>")
    handle.text " "
    handle.addClass "ui-resizable-" + name
    handle.addClass "ui-resizable-handle"
    handle.addClass "resize-handle"
    handle.addClass name
    handle.addClass "do_not_drag"
    element.append handle
    jquery_ui_args[name] = handle

  return jquery_ui_args

add_item = ->

  grid_size = $("#page_content").width()/num_cols
  
  new_item = $ "<div></div>"
  new_item.css
    backgroundColor:"rgba(255,255,255,.9)"
    border:"1px dashed #ccc"
    width: grid_size*10 - 4 #2 for border width
    height: grid_size*7 - 4
    zIndex: 10
    textAlign: "center"
    position: "absolute"
    top: 0
    left: 0

  wrapper = new_item
  
  jquery_resize_handles = add_resize_handles wrapper
  $("#page_content").append wrapper
  
  content = $ "<img />"
  content.attr 'src', 'http://img716.imageshack.us/img716/1621/pokemon1.png'
  content.attr 'alt', 'happy pokemon'

  delay ->
    content.origWidth = content.width()
    content.origHeight = content.height()
    content.aspectRatio = content.origWidth / content.origHeight

  new_item.prev_size =
    width: -1
    height: -1

  resize_handler = ->

    delay ->
      if new_item.width() != new_item.prev_size.width or new_item.height() != new_item.prev_size.height
        delay update_wrap
      wrapper.prev_location =
        width: new_item.width()
        height: new_item.height()
      new_aspect_ratio = new_item.width()/new_item.height()
      if new_aspect_ratio > content.aspectRatio
        content.height(new_item.height())
        content.width(content.height()*content.aspectRatio)
      else
        content.width(new_item.width())
        content.height(content.width()/content.aspectRatio)

  new_item.append content
  resize_handler()

  boxes.push wrapper

  wrapper.prev_location =
    left: -1
    top: -1

  item_drag_handler = (event, ui) ->
    if ui.position.left != wrapper.prev_location.left or ui.position.top != wrapper.prev_location.top
      setTimeout update_wrap, 50
    wrapper.prev_location = ui.position
  
  wrapper.draggable
    grid:[grid_size,grid_size]
    containment:"#page_content"
    cancel: ".do_not_drag"
    drag: item_drag_handler

  resizable_options =
    grid:[grid_size,grid_size]
    resize: resize_handler
    handles: jquery_resize_handles
    containment: "#page_content"

  new_item.resizable resizable_options

  window.sel.set_deselect_area ".sidebar"
  selectable = new window.sel.Deleteable(wrapper)
  
  wrapper.find(".resize-handle").hide()
  wrapper.bind "select", ->
    wrapper.find(".resize-handle").show()
  wrapper.bind "deselect", ->
    wrapper.find(".resize-handle").hide()

add_header = ->
  new_header = $ "<h1>This is a header</h1>"
  $("#page_content").append new_header
  make_editable new_header

  make_wrap new_header

add_section_title = ->
  new_header = $ "<h2>This is a section title</h2>"
  $("#page_content").append new_header
  make_editable new_header

  make_wrap new_header

add_body_text = ->
  new_text = $ "<div>Body text</div>"
  new_text.addClass "text_section"
  $("#page_content").append new_text

  make_editable new_text, true

  make_wrap new_text

make_draggable = (element) ->
  element.addClass "sortable"
  $("#page_content").sortable
    items: ".sortable"
    handle: ".handle"

make_editable = (element, formattable=false) ->

  editable_part = $("<div></div>")
  editable_part.html(element.html())
  element.html("")

  element.append(editable_part)

  element.state = "preview"

  if formattable
    attachEvents(editable_part)
  
  editable_part.attr("contenteditable", "true")

  add_drag_handle element
  make_draggable element

  add_close_button element

  element.mouseenter ->
    if element.state == "preview"
      element.css("border", "1px solid #ccc")
      element.css("padding", 4)
  element.mouseleave ->
    if element.state == "preview"
      element.css("border", "none")
      element.css("padding", 5)

  editable_part.click (event) ->
    if element.state == "preview"
      toolbar = $('#floatingbar')
      if formattable
        delay -> 
          toolbar.css("display", "block")
      element.css("border", "1px dashed #ccc")
      element.state = "editing"
      setEvent = ->
        $(".page").one "click", ->
          element.state = "preview"
          if formattable
            toolbar.css("display", "none")
          element.css("border", "none")
          element.css("padding", 5)
      setTimeout setEvent, 100
    else if element.state == "editing"
      event.stopPropagation()

wrapping_elements = []
boxes = []

make_wrap = (element) ->
  wrapping_elements.push element

  update_wrap()

update_wrap = ->
  width = $("#page_content").width()
  grid_size = width/num_cols
  
  dimensions = []
  for box in boxes
    pos = box.position()
    dimensions.push
      left: pos.left
      top: pos.top
      right: pos.left + box.width()
      bottom: pos.top + box.height()

  dimensions.sort (a, b) ->
    a.bottom - b.bottom

  if dimensions.length > 0
    max_y = dimensions[dimensions.length - 1].bottom/grid_size + 1
  else
    max_y = 5
  left_constraint_grid = []
  right_constraint_grid = []

  for i in [0..max_y]
    left_constraint_grid.push(0)
    right_constraint_grid.push(720)

  get_borders_canvas().attr("height", max_y*grid_size)

  for dim in dimensions
    top_grid = Math.floor(dim.top/grid_size + .5)
    bottom_grid = Math.floor(dim.bottom/grid_size - .5)

    if dim.left - left_constraint_grid[top_grid] > width - dim.right
      for grid_index in [top_grid..bottom_grid]
        right_constraint_grid[grid_index] = Math.min(right_constraint_grid[grid_index], dim.left)
    else
      for grid_index in [top_grid..bottom_grid]
        left_constraint_grid[grid_index] = Math.max(left_constraint_grid[grid_index], dim.right)

  

  draw_borders = ->
    canvas = get_borders_canvas() 
    context = canvas.get(0).getContext("2d")

    context.clearRect 0, 0, canvas.width(), canvas.height()

    context.beginPath()
    context.moveTo left_constraint_grid[0], 0

    for item, i in left_constraint_grid
      context.lineTo item, i*grid_size

    context.stroke()
    
    context.beginPath()
    context.moveTo(right_constraint_grid[0], 0)

    for item, i in right_constraint_grid
      context.lineTo item, i*grid_size

    context.stroke()

  draw_borders()

  wrapping_elements.sort (a,b) ->
    a.offset().top - b.offset().top

  for element in wrapping_elements
    element.css
      marginLeft: 0
      marginRight: 0

    top_grid_pos = Math.floor((element.position().top + parseInt element.css("marginTop"))/grid_size)
    bottom_grid_pos = Math.floor((element.position().top + parseInt(element.css("marginTop")) + element.height())/grid_size)

    left_max = Math.max.apply Math, (left_constraint_grid[top_grid_pos..bottom_grid_pos])
    right_max = Math.min.apply Math, (right_constraint_grid[top_grid_pos..bottom_grid_pos])
    console.log left_max

    margin = 10
    
    if left_max > 0
      left_max += margin

    if right_max < width
      right_max -= margin

    element.css
      marginLeft: left_max
      marginRight: width - right_max

measure = (element, width, text_length) ->
  copy = element.clone()
  copy.text(copy.text().slice(0, text_length))
  copy.css
    position: "absolute"
    right: 9999
    "width": width
  element.parent().append(copy)
  return copy.innerHeight()

split_text = (element, width, height) ->
  text = element.text()
  num_chars = text.length;

  binary_search = (low, high) ->
    if high-low < 2
      return low

    boundary = (high+low)/2

    height_measure = measure(element, width, boundary)

    if height_measure > height
      return binary_search(low, boundary)
    else
      return binary_search(boundary, high)

  exact_char = binary_search(0, num_chars)

  return [text.slice(0, exact_char), text.slice(exact_char)]

$ ->
  $("#add_rectangle").click ->
    add_item()
  $("#add_header").click ->
    add_header()
  $("#add_section_title").click ->
    add_section_title()
  $("#add_text_section").click ->
    add_body_text()
