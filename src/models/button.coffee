class Button
  @_buttons = {}
  @find: (id) ->
    @_buttons[id]


  @onClick: (event) ->
    target = event.currentTarget
    pinned = $(target).next().find(':checkbox')

    if pinned.attr('checked') == 'checked'
      if event.which == 1 && !event.metaKey && !event.shiftKey
        # We have a normal click, pin this tab
        chrome.tabs.getCurrent (tab) ->
          chrome.tabs.update tab.id, {'pinned': true}
        return

      # Mod-click or middle, don't lose focus or kill this tab
      chrome.tabs.create
        'pinned': true
        'selected': false
        'url': $(target).attr("href")

      return false


  constructor: (@bookmark) ->
    Button._buttons[@bookmark.id] = this
    @generateElements()
    @applySettings()


  generateElements: ->
    @li = $('<li>')
      .attr('id', "bookmark-#{@bookmark.id}")

    @link = $('<a>')
      .click Button.onClick

    @img_div = $('<div>')
      .attr('class', 'link-image')
      .bind('dragenter', @onDragEnter)
      .bind('dragleave', @onDragLeave)
      .bind('dragover', @onDragOver)
      .bind('drop', @onDrop)

    @setting_div = $('<div>')
      .attr('class', 'settings')

    @color_select = $('<select>')
      .change(@onColorChange)

    for color in Settings.COLORS
      opt = $('<option>')
        .text(color)
      @color_select.append opt

    @pin_label = $('<label>')
      .text('Pinned')
      .attr('class', 'pinlabel')

    @pin_check = $('<input>')
      .attr('type', 'checkbox')
      .change(@onPinChange)

    @li.append @link
    @link.append @img_div
    @li.append @setting_div
    @setting_div.append @color_select
    @setting_div.append @pin_label
    @pin_label.append @pin_check


  onColorChange: (event) =>
    val = $(event.target).val()
    @link.attr('class', val)

    settings = new Settings @bookmark
    settings.save 'color', val


  onPinChange: (event) =>
    checked = $(event.target).attr('checked') == 'checked'
    @link.data('pinned', checked)

    settings = new Settings @bookmark
    settings.save 'pinned', checked


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


  onDrop: (event) =>
    dt = event.originalEvent.dataTransfer

    target_img = $(event.target)
    target_img.removeClass('dragover')

    return true if dt.types[0] != "Files"
    if dt.files.length != 1
      event.stopPropagation()
      return false

    file = dt.files[0]

    if file.size > (70 * 1024)
      alert 'That file is too big!'
    else if file.type.indexOf("image") == 0
      reader = new FileReader()
      reader.onload = (e) =>
        imgsrc = e.target.result
        target_img.css("background", "url(#{imgsrc})")
          .css('background-size', "100%")

        settings = new Settings @bookmark
        settings.save 'rawimg', imgsrc

      reader.readAsDataURL(file)

    event.stopPropagation()
    return false


  applySettings: ->
    settings = new Settings @bookmark

    @link.attr('href', @bookmark.url)
      .attr('class', settings.read 'color')
      .data('pinned', settings.read 'pinned')

    @img_div.attr('class', "link-image")
      .css('background', "url(#{settings.read 'rawimg'})")
      .css('background-size', "100%")

    @color_select.val(settings.read 'color')
    @pin_check.attr('checked', settings.read 'pinned')
