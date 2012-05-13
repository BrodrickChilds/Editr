unless window.utils
  window.utils = {}

  ###
    delay:
    Delays the execution of func by 50 ms.
  ###

  window.utils.delay = (func) ->
    setTimeout func, 50
  
  ###
    measure:
    Measures the height element would have if given a certain width.
  ###

  measure = (element, width) ->

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
 
