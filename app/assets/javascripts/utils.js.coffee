unless window.utils
  window.utils = {}

  ###
    delay:
    Delays the execution of func by 50 ms.
  ###

  window.utils.delay = (func) =>
    setTimeout func, 50

  ###
    get_line_height:
    Measures the height of one line of text at the current font and size,
    not counting padding.
  ###

  window.utils.get_line_height = (element) ->
    copy = element.clone()
    copy.text("a")
    copy.css
      padding: 0
      border: 0
      position: "absolute"
      right: 9999

    element.parent().append(copy)
    height = copy.innerHeight()

    copy.remove()

    return height

  ###
    measure:
    Measures the height element would have if given a certain width.
  ###

  window.utils.measure = (element, width) ->

    # creates a copy of the element in a location off of the page
    copy = element.clone()
    copy.css
      position: "absolute"
      right: 9999
      "width": width

    # adds to the parent of element so that inherited properties are maintained
    element.parent().append(copy)
    height = copy.innerHeight()

    # deletes the copy
    copy.remove()

    return height
 
