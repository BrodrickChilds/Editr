unless window.controls
  window.controls = {}

  window.controls.add_delete_button = (element) ->
    button = $ "<div></div>"
    button.text "X"
    button.addClass "close-button"
    element.append button
    return button

  window.controls.add_resize_handles = (element) ->
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
 
  window.controls.add_resize_handles_to_selectable = (selectable) ->
    element = selectable.element

    jquery_ui_args = window.controls.add_resize_handles element

    element.find(".resize-handle").hide()
    element.bind "select", ->
      element.find(".resize-handle").show()
    element.bind "deselect", ->
      element.find(".resize-handle").hide()

    return jquery_ui_args
  
