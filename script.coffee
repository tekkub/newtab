
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

  $('.link-image')
    .bind 'drop', (ev) ->
      dt = ev.originalEvent.dataTransfer
      console.log(dt.types, dt.files[0])

      key = ev.target.dataset.key
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

$('#settings-toggle').click ->
  $('.settings').toggle()
  return false

chrome.storage.sync.get null, (data) ->
  # console.log(data)
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
        row.append li

        link = $('<a>')
          # .attr('id', "link-#{bookmark.id}")
          .attr('class', syncdata["color-#{bookmark.url}"])
          .attr('href', bookmark.url)
          .data('pinned', syncdata["pinned-#{bookmark.url}"])
        li.append link

        link.click (e) ->
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

        img_div = $('<div>')
          .attr('class', "link-image")
          # .data('key', bookmark.id)
          .css('background', "url(#{syncdata["image-#{bookmark.url}"]})")
          # .css('background', "url(https://dl.dropbox.com/s/kzaj5ges3vw7oo8/gmail.png?dl=1)")
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
          key = "color-#{bookmark.url}"
          data = {}
          data[key] = val
          link.attr('class', val)
          chrome.storage.sync.set data

        img_url = $('<input>')
          .attr('class', 'img-url')
          .val(syncdata["image-#{bookmark.url}"])
          .change ->
            key = "image-#{bookmark.url}"
            data = {}
            data[key] = $(this).val()
            chrome.storage.sync.set data
            img_div.css('background', "url(#{data[key]})")
        setting_div.append img_url

        pin_label = $('<label>')
          .text('Pinned')
        setting_div.append pin_label

        pin_check = $('<input>')
          .attr('type', 'checkbox')
          .attr('checked', syncdata["pinned-#{bookmark.url}"])
          .change ->
            key = "pinned-#{bookmark.url}"
            data = {}
            data[key] = ($(this).attr('checked') == 'checked')
            chrome.storage.sync.set data
            link.data('pinned', data[key])
        pin_label.append pin_check

