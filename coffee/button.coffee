class Button
  @_buttons = {}
  @find: (id) ->
    @_buttons[id]


  constructor: (@bookmark) ->
    Button._buttons[bookmark.id] = this

    @li = $('<li>')
      .attr('id', "bookmark-#{bookmark.id}")

    @link = $('<a>')
      .click @onClick
    @li.append @link

    @img_div = $('<div>')
      .attr('class', 'link-image')
      .bind('dragenter', @onDragEnter)
      .bind('dragleave', @onDragLeave)
      .bind('dragover', @onDragOver)
      .bind('drop', @onDrop)

    @link.append @img_div


  onClick: (event) ->
    if $(this).data('pinned')
      if event.which == 1 && !event.metaKey && !event.shiftKey
        # We have a normal click, pin this tab
        chrome.tabs.getCurrent (tab) ->
          chrome.tabs.update tab.id, {'pinned': true}
        return

      # Mod-click or middle, don't lose focus or kill this tab
      chrome.tabs.create
        'pinned': true
        'selected': false
        'url': $(this).attr("href")

      return false


  onDragEnter: (event) ->
    # Update the drop zone class on drag enter/leave
    $(event.target).addClass('dragover')
    return false


  onDragLeave: (event) ->
    $(event.target).removeClass('dragover')
    return false


  onDragOver: (event) ->
    # Allow drops of any kind into the zone.
    return false


  onDrop: (event) ->
    dt = event.originalEvent.dataTransfer

    target_img = $(event.target)
    target_img.removeClass('dragover')

    return true if dt.types[0] != "Files"
    if dt.files.length != 1
      event.stopPropagation()
      return false

    file = dt.files[0]

    if file.type.indexOf("image") == 0
      reader = new FileReader()
      reader.onload = (e) ->
        imgsrc = e.target.result
        target_img.css("background", "url(#{imgsrc})")
          .css('background-size', "100%")

        key = @bookmark.id
        chrome.bookmarks.get key, (bookmark) ->
          bookmark_data = getBookmarkData(bookmark[0])
          bookmark_data['rawimg'] = imgsrc
          saveBookmarkData(key, bookmark_data)

      reader.readAsDataURL(file)

    event.stopPropagation()
    return false

