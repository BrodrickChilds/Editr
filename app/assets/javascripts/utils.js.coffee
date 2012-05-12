unless window.utils
  window.utils = {}

  window.utils.delay = (func) ->
    setTimeout func, 50
 
