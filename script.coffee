
syncdata = null
colors = [
  'silver'
  'black'
  'purple'
  'blue'
  'green'
  'yellow'
  'orange'
  'red'
  'pink'
]


injectBookmark = (bookmark) ->
  settings = getBookmarkData(bookmark)
  li = $("#bookmark-#{bookmark.id}")

  link = li.children('a')
  link.data('bookmarkid', bookmark.id)
    .attr('href', bookmark.url)
    .attr('class', settings["color"])
    .data('pinned', settings["pinned"])

  img_div = link.children('div')
  img_div.attr('class', "link-image")
    .css('background', "url(#{settings["rawimg"]})")
    .css('background-size', "100%")

  setting_div = li.children('div.settings')
  setting_div.children('select')
    .val(settings['color'])
  setting_div.children('label.pinlabel').children('input')
    .attr('checked', settings["pinned"])


getBookmarkData = (bookmark) ->
  hash = bookmark.title
  default_data = {
    'id': bookmark.id,
    'link': bookmark.url
  }

  return default_data if hash == ''

  raw = localStorage[hash]
  if raw
    data = JSON.parse(raw)
    data['id'] = bookmark.id
    return data

  else
    $.ajax
      url: "https://api.github.com/gists/#{hash}"
      type: 'GET'
      success: (data, textStatus, jqXHR) ->
        console.log("Gist received #{hash}", data)
        localStorage[hash] = data['files']['sync.json']['content']
        injectBookmark(bookmark)
    return default_data


saveBookmarkData = (key, data) ->
  content = JSON.stringify(data)
  $.ajax
    url: 'https://api.github.com/gists'
    type: 'POST'
    dataType: 'json'
    data: JSON.stringify
      'description': 'tek newtab sync data'
      'public': false
      'files': {
        'sync.json': {
          'content': content
        }
      }
    success: (data, textStatus, jqXHR) ->
      console.log("gisted", data)
      chrome.bookmarks.update(key, {title: data.id})
      localStorage[data.id] = content


renderLinks = (data) ->
  template = Handlebars.compile($("#links-template").html())
  html     = template({rows: data})
  $('#links').html html

  $("a[data-pinned='true']").click (e) ->
    if e.which == 1 && !e.metaKey && !e.shiftKey
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


$('#settings-toggle').click ->
  $('.settings').toggle()
  return false

chrome.storage.sync.get null, (data) ->
  console.log(data)
  syncdata = data

  newdata = []
  chrome.bookmarks.getTree (tree) ->
    mytree = null
    $.each tree[0].children[1].children, (i,subtree) ->
      mytree = subtree if subtree.title == 'newtab'

    $.each mytree.children, (i,subtree) ->
      row = $('<ul>')
      $('body').append row

      $.each subtree.children, (i,bookmark) ->
        li = $('<li>')
          .attr('id', "bookmark-#{bookmark.id}")
        row.append li

        link = $('<a>')
          .click (e) ->
            if link.data('pinned')
              if e.which == 1 && !e.metaKey && !e.shiftKey
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
        li.append link

        key = bookmark.id
        img_div = $('<div>')
          .attr('class', 'link-image')
          .bind 'drop', (ev) ->
            dt = ev.originalEvent.dataTransfer

            target_img = $(ev.target)
            target_img.removeClass('dragover')

            return true if dt.types[0] != "Files"
            if dt.files.length != 1
              ev.stopPropagation()
              return false

            file = dt.files[0]

            if file.type.indexOf("image") == 0
              reader = new FileReader()
              reader.onload = (e) ->
                imgsrc = e.target.result
                target_img.css("background", "url(#{imgsrc})")
                  .css('background-size', "100%")

                chrome.bookmarks.get key, (bookmark) ->
                  bookmark_data = getBookmarkData(bookmark[0])
                  bookmark_data['rawimg'] = imgsrc
                  saveBookmarkData(key, bookmark_data)

              reader.readAsDataURL(file)

            ev.stopPropagation()
            return false

          .bind 'dragenter', (ev) ->
            # Update the drop zone class on drag enter/leave
            $(ev.target).addClass('dragover')
            return false

          .bind 'dragleave', (ev) ->
            $(ev.target).removeClass('dragover')
            return false

          .bind 'dragover', (ev) ->
            # Allow drops of any kind into the zone.
            return false
        link.append img_div

        setting_div = $('<div>')
          .attr('class', 'settings')
        li.append setting_div

        color_select = $('<select>')
        setting_div.append color_select

        for color in colors
          opt = $('<option>')
            .text(color)
          color_select.append opt

        color_select.change ->
          val = $(this).val()
          link.attr('class', val)

          settings = getBookmarkData(bookmark)
          settings['color'] = val
          saveBookmarkData(bookmark.id, settings)

        pin_label = $('<label>')
          .text('Pinned')
          .attr('class', 'pinlabel')
        setting_div.append pin_label

        pin_check = $('<input>')
          .attr('type', 'checkbox')
          .attr('checked', syncdata["pinned-#{bookmark.url}"])
          .change ->
            checked = $(this).attr('checked') == 'checked'
            link.data('pinned', checked)

            settings = getBookmarkData(bookmark)
            settings['pinned'] = checked
            saveBookmarkData(bookmark.id, settings)

        pin_label.append pin_check

        injectBookmark(bookmark)


