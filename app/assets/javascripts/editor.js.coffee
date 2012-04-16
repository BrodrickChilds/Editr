num_cols = 24
margin = 5

get_grid_canvas = -> $("#grid")
get_borders_canvas = -> $("#borders")
get_page_content = -> $("#page_content")

draw_grid = ->
  grid = get_grid_canvas()
  context = grid.get(0).getContext "2d"

  grid_width = grid.width()
  cell_size = grid_width/num_cols

  grid_height = grid.height()
  num_rows = grid_height/cell_size

  context.strokeStyle = "#eee"
  context.lineWidth = 1

  for col in [0..num_cols]
    context.beginPath()
    x_pos = Math.floor col*cell_size
    context.moveTo x_pos, 0
    context.lineTo x_pos, grid_height
    context.stroke()
  for row in [0..num_rows]
    context.beginPath()
    y_pos = Math.floor row*cell_size
    context.moveTo 0, y_pos
    context.lineTo grid_width, y_pos
    context.stroke()

add_item = ->
  wrapper = $ "<div></div>"
  wrapper.css
    position: "absolute"
    top: 0
    left: 0

  grid_size = $("#page_content").width()/num_cols
  
  new_item = $ "<div></div>"
  new_item.css
    backgroundColor:"rgba(255,255,255,.9)"
    border:"1px dashed #ccc"
    width: grid_size*5 - 4 #2 for border width
    height: grid_size*5 - 4
    overflow: "hidden"
    zIndex: 10

  $("#page_content").append wrapper
  wrapper.append new_item
  
  new_item.resizable
    grid:[grid_size,grid_size]
  

  content = $ "<img />"
  content.attr 'src', 'http://img716.imageshack.us/img716/1621/pokemon1.png'
  content.attr 'alt', 'happy pokemon'

  new_item.append content

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

  make_editable new_text

  make_wrap new_text

make_editable = (element) ->
  element.state = "preview"

  element.mouseenter ->
    if element.state == "preview"
      element.css("border", "1px solid #ccc")
      element.css("padding", 4)
  element.mouseleave ->
    if element.state == "preview"
      element.css("border", "none")
      element.css("padding", 5)

  element.click (event) ->
    if element.state == "preview"
      element.css("border", "1px dashed #ccc")
      element.attr("contenteditable", "true")
      element.state = "editing"
      setEvent = ->
        $(".page").one "click", ->
          element.state = "preview"
          element.removeAttr "contenteditable"
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

  max_y = dimensions[dimensions.length - 1].bottom/grid_size + 1
  left_constraint_grid = []
  right_constraint_grid = []

  for i in [0..max_y]
    left_constraint_grid.push(0)
    right_constraint_grid.push(720)

  get_borders_canvas().attr("height", max_y*grid_size)
  $("#page_content").css "minHeight", max_y*grid_size

  for dim in dimensions
    top_grid = Math.floor(dim.top/grid_size + .5)
    bottom_grid = Math.floor(dim.bottom/grid_size - .5)

    if dim.left > width - dim.right
      for grid_index in [top_grid..bottom_grid]
        right_constraint_grid[grid_index] = Math.min(right_constraint_grid[grid_index], dim.left)
    else
      for grid_index in [top_grid..bottom_grid]
        left_constraint_grid[grid_index] = Math.max(left_constraint_grid[grid_index], dim.right)

  console.log [left_constraint_grid, right_constraint_grid]  

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

  wrapping_elements.sort (a,b) ->
    a.offset().top - b.offset().top

  for element in wrapping_elements
    element.css "background", "red"

measurer = $ "<div></div>"
$ ->
  measurer.css 
    position:"absolute"
    left:"2000px"
    top:"0px"
  
  $("body").append measurer

measure = (text, width) ->
  measurer.css {"width":width}
  measurer.text text
  return measurer.innerHeight()

split_text = (text, width, height) ->
  num_chars = text.length;

  binary_search = (low, high) ->
    if high-low < 2
      return low

    boundary = (high+low)/2

    height_measure = measure(text.slice(0,boundary), width)

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
