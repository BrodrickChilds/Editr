#= require controls

unless window.sel
  window.sel = {}
  window.sel.selected_object = null

  window.sel.set_deselect_area = (element) ->
    window.sel.deselect_area = $(element)

  class window.sel.Selectable

    constructor: (@element) ->
      @element.mousedown @_select
      @element.mouseenter @mouseover
      @element.mouseleave @mouseout

      @selected = false

    _select: =>
      if this isnt window.sel.selected_object
        @element.trigger "select"
        @select()

        if window.sel.selected_object?
          window.sel.selected_object._deselect()

        window.sel.selected_object = this

        window.sel.deselect_area.one("mousedown", @_deselect)

        @selected = true

    _deselect: =>
      if this is window.sel.selected_object
        @element.trigger "deselect"
        @deselect()

        window.sel.selected_object = null

        @selected = false

    select: =>
      @element.removeClass "mouseover"
      @element.addClass "selected"

    deselect: =>
      @element.removeClass "selected"
      @element.removeClass "mouseover"

    mouseover: =>
      unless @selected
        @element.addClass "mouseover"

    mouseout: =>
      @element.removeClass "mouseover"      
     
  class window.sel.Deleteable extends window.sel.Selectable
    constructor: (@element) ->
      @delete_button = window.controls.add_delete_button(@element)
      @delete_button.click @delete
      @delete_button.hide()
      console.log @element
      super(@element)

    mouseover: =>
      super()
      @delete_button.show()
      super()

    mouseout: =>
      super()
      unless @selected
        @delete_button.hide()
      super()

    select: =>
      super()
      @delete_button.show()

    deselect: =>
      super()
      @delete_button.hide()

    delete: =>
      @_deselect()
      @element.remove()
