class Button
  constructor: (@bookmark) ->
    @li = $('<li>')
    @li.attr('id', "bookmark-#{bookmark.id}")

  getListItem: ->
    return @li
