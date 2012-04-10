get_grid_canvas = -> $("#grid")

draw_grid = (num_cols = 12) ->
  grid = get_grid_canvas()
  context = grid.get(0).getContext("2d")

  grid_width = grid.width()
  cell_size = grid_width/num_cols

  grid_height = grid.height()
  num_rows = grid_height/cell_size

  context.strokeStyle = "rgb(200,200,200)"
  context.lineWidth = 1

  for col in [0..num_cols]
    context.beginPath()
    x_pos = Math.floor col*cell_size
    context.moveTo(x_pos, 0)
    context.lineTo(x_pos, grid_height)
    context.stroke()
  for row in [0..num_rows]
    context.beginPath()
    y_pos = Math.floor row*cell_size
    context.moveTo(0, y_pos)
    context.lineTo(grid_width, y_pos)
    context.stroke()

add_item = ->
  new_item = $("<div></div>")
  new_item.css(
    background:"#f00",
    width:100,
    height:100,
    position:"absolute",
    left:0,
    top:0
  );
  $("#layer").append(new_item)


$ ->
  draw_grid()
  $("#add_rectangle").click ->
    add_item()

