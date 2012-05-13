#= require utils
#= require selectable
#= require controls

num_cols = 24
margin = 5

get_grid_canvas = -> $("#grid")
get_borders_canvas = -> $("#borders")
get_page_content = -> $("#page_content")

add_item = ->

  boxes.push wrapper
  
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
  new_text.addClass "body_text"
  $("#page_content").append new_text

  make_editable new_text, true

  make_wrap new_text

make_draggable = (element) ->
  element.addClass "sortable"
  $("#page_content").sortable
    items: ".sortable"
    handle: ".handle"

make_editable = (element, formattable=false) ->
  wrapping_text = new window.text.WrappingText element
  make_draggable element
  if formattable
    element.bind "select", ->
      $("#floatingbar").show()
    element.bind "deselect", ->
      $("#floatingbar").hide()
  if formattable
    attachEvents(wrapping_text.content)


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

  #draw_borders()

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
  window.sel.set_deselect_area ".sidebar"
  $("#add_rectangle").click ->
    image_tag = $ "<img />"
    image_tag.attr 'src', 'http://img716.imageshack.us/img716/1621/pokemon1.png'
    image_tag.attr 'alt', 'happy pokemon'
    grid_size = $("#page_content").width()/num_cols

    image = new window.image_box.ImageBox(image_tag, $("#page_content"), grid_size)

    boxes.push image.element

    image.element.bind "modified", update_wrap
  $("#add_header").click ->
    add_header()
  $("#add_section_title").click ->
    add_section_title()
  $("#add_text_section").click ->
    add_body_text()
