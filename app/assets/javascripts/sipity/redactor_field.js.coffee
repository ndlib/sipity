class RedactorTextInput
  constructor: (@fieldElement) ->
    if @fieldElement.length > 0
      @setupField()

  setupField: ->
    @fieldElement.redactor({
      buttonSource: true
      focus: true
      buttons: ['bold', 'italic']
    })

class RedactorTextArea
  constructor: (@fieldElement) ->
    if @fieldElement.length > 0
      @setupField()

  setupField: ->
    @fieldElement.redactor({
      buttonSource: true
      focus: true
      formatting: ['p', 'blockquote', 'h2', 'h3', 'h4']
      buttons: ['formatting', 'bold', 'italic', 'unorderedlist', 'orderedlist', 'deleted']
      minHeight: '16em'
    })


jQuery ($) ->

  setupRedactorTextInputs = () ->
    field = $(".redactor-input")
    if field.length > 0
      new RedactorTextInput(field)

  setupRedactorTextAreas = () ->
    field = $(".redactor-area")
    if field.length > 0
      new RedactorTextArea(field)

  ready = ->
    setupRedactorTextInputs()
    setupRedactorTextAreas()

  $(document).ready(ready)
  $(document).on('page:load', ready)
