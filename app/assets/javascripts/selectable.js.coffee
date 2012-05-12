#= require controls

unless window.sel
  window.sel = {}
  window.sel.selected_object = null

  window.sel.set_deselect_area = (element) ->
    window.sel.deselect_area = $(element)

  class window.sel.Selectable

    constructor: (@element) ->
      @element.mousedown @select
      @element.mouseenter @mouseover
      @element.mouseleave @mouseout

      @selected = false

    select: ->
      if this isnt window.sel.selected_object
        @element.trigger "select"

        if window.sel.selected_object?
          window.sel.selected_object.deselect()

        window.sel.selected_object = this

        window.sel.deselect_area.one("mousedown", @deselect)

        @selected = true

    deselect: ->
      if this is window.sel.selected_object
        @element.trigger "deselect"

        window.sel.selected_object = null

        @selected = false

    mouseover: ->

    mouseout: ->
      
     
  class window.sel.Deleteable extends window.sel.Selectable
    constructor: (@element) ->
      @delete_button = window.controls.make_delete_button()
      @element.append @delete_button
      @delete_button.click @delete
      @delete_button.hide()
      console.log @element
      super(@element)

    mouseover: =>
      @delete_button.show()
      super()

    mouseout: =>
      unless @selected
        @delete_button.hide()
      super()

    select: =>
      @delete_button.show()
      super()

    deselect: =>
      @delete_button.hide()
      super()

    delete: =>
      @element.remove()
