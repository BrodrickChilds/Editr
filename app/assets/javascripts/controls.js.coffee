unless window.controls
  window.controls = {}

  window.controls.make_delete_button = ->
    button = $ "<div></div>"
    button.text "X"
    button.addClass "close-button"
    return button
 
