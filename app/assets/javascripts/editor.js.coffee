#= require utils
#= require selectable
#= require controls

num_cols = 24
margin = 5

get_grid_canvas = -> $("#grid")
get_borders_canvas = -> $("#borders")
get_page_content = -> $("#page_content")
  
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

make_wrap = (element) ->
  split_wrap()

split_wrap = ->
  width = $("#page_content").width()
  grid_size = width/num_cols

  dimensions = []
  for box in window.image_box.list
    box=box.element
    pos = box.position()
    dimensions.push
      left: pos.left
      top: pos.top
      right: pos.left + box.width()
      bottom: pos.top + box.height()

  dimensions.sort (a, b) ->
    a.bottom - b.bottom

  # to be safe, we'll just add 100 pixels so we calculate a little past the bottom
  if dimensions.length > 0
    max_y = dimensions[dimensions.length - 1].bottom + 100
  else
    max_y = 100

  for text in window.text.wrapping_texts
    element = text.element
    
    line_height = window.utils.get_line_height element

    text_top = element.offset().top - $("#page_content").offset().top

    current_y = text_top

    occupied = []
    while current_y < max_y
      new_row = (0 for x in [0...num_cols])
      occupied.push new_row
      current_y += line_height

    for dimension in dimensions
      y_start_index = (dimension.top - text_top)/line_height
      y_end_index = (dimension.bottom - text_top)/line_height
      y_start_index = Math.floor(y_start_index)
      y_end_index = Math.floor(y_end_index)
      
      x_start_index = dimension.left/grid_size
      x_end_index = dimension.right/grid_size
      x_start_index = Math.floor(x_start_index)
      x_end_index = Math.floor(x_end_index)

      for row_index in [y_start_index..y_end_index]
        for col_index in [x_start_index..x_end_index]
          if occupied[row_index]
            occupied[row_index][col_index] = 1

    copy = text.content.clone()
    copy.css
      position: "absolute"
      right: 9999

    text.content.html ""

    text.element.append copy

    index = 0

    skipped = 0

    while copy.text()
      if occupied[index]
        stretches = get_largest_stretch occupied[index]
      else
        stretches = [[0, num_cols]]
     
      if stretches and stretches[0][1] > 6
        results = rectangle_slice(copy, (stretches[0][1]-1)*grid_size, line_height)
        remaining_text = results[1]
        copy.text(remaining_text)

        new_section = $ "<div></div>"
        new_section.css
          marginLeft: stretches[0][0]*grid_size
          width: stretches[0][1]*grid_size
          marginTop: skipped*line_height
        new_section.text results[0]

        text.content.append new_section

        skipped = 0
      else
        skipped += 1

      index += 1

get_largest_stretch = (row) ->
  best = null
  current = null
  index = 0
  for item in row
    if current and item == 0
      current[1] += 1
    else if current and item == 1
      if best
        if best[0][1] == current[1]
          best.push current
          current = null
        else if best[0][1] < current[1]
          best = [current]
          current = null
        else
          current = null
      else
        best = [current]
        current = null
    else if item == 0
      current = [index,1]
    index += 1
  if current
    if best
      if best[0][1] == current[1]
        best.push current
        current = null
      else if best[0][1] < current[1]
        best = [current]
        current = null
      else
        current = null
    else
      best = [current]
    
  return best

rectangle_slice = (element, width, height) ->
  get_height = (cutoff) ->
    window.utils.measure(html_slice(element, cutoff), width)

  binary_search = (low, high) ->
    avg = Math.floor (low+high)/2

    if low >= high-1
      return high
    else if get_height(avg) <= height
      return binary_search(avg, high)
    else
      return binary_search(low, avg)

  cutoff = binary_search(0, element.text().length)
  if cutoff != element.text().length
    while element.text().slice(cutoff, cutoff+1) != ' '
      cutoff -= 1

  return [element.text().slice(0, cutoff), element.text().slice(cutoff)]

html_slice = (element, cutoff) ->
  copy = element.clone()
  copy.text element.text().slice(0,cutoff)

  copy.css
    position: "absolute"
    right: 9999
    padding: 0

  element.parent().append copy
 
  return copy

$ ->
  window.sel.set_deselect_area ".sidebar"
  $("#add_rectangle").click =>
    image_tag = $ "<img />"
    image_tag.attr 'src', 'http://img716.imageshack.us/img716/1621/pokemon1.png'
    image_tag.attr 'alt', 'happy pokemon'
    grid_size = $("#page_content").width()/num_cols

    image = new window.image_box.ImageBox(image_tag, $("#page_content"), grid_size)

    image.element.bind "modified", split_wrap
  $("#add_header").click ->
    add_header()
  $("#add_section_title").click ->
    add_section_title()
  $("#add_text_section").click ->
    add_body_text()

###
  The below method is deprecated, and is currently being replaced with a new wrapping method.
###
  
update_wrap_boxes = ->
  width = $("#page_content").width()
  grid_size = width/num_cols
  
  dimensions = []
  for box in window.image_box.list
    box=box.element
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

  window.text.wrapping_texts.sort (a,b) ->
    a.element.offset().top - b.element.offset().top

  for wrapping_text in window.text.wrapping_texts
    element = wrapping_text.element
    element.css
      marginLeft: 0
      marginRight: 0

    top_grid_pos = Math.floor((element.position().top + parseInt element.css("marginTop"))/grid_size)
    bottom_grid_pos = Math.floor((element.position().top + parseInt(element.css("marginTop")) + element.height())/grid_size)

    left_max = Math.max.apply Math, (left_constraint_grid[top_grid_pos..bottom_grid_pos])
    right_max = Math.min.apply Math, (right_constraint_grid[top_grid_pos..bottom_grid_pos])

    margin = 10
    
    if left_max > 0
      left_max += margin

    if right_max < width
      right_max -= margin

    element.css
      marginLeft: left_max
      marginRight: width - right_max
