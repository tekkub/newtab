
Settings.initialize

syncdata = null

$.parse.init
  app_id: "xUAcXfMivxbjqOhtLuX9e0Nz7zO0aL0ieq93swiN"
  rest_key: "tbVr6U9goimUx4m0LHE5B24MtibdCYqiTlSnKyk2"


injectBookmark = (bookmark) ->
  settings = Settings.fetch bookmark
  butt = Button.find bookmark.id
  li = butt.li
  link = butt.link

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


saveBookmarkData = (key, data) ->
  delete data.id
  delete data.objectId
  delete data.createdAt
  delete data.updatedAt
  console.log "New data", data
  $.parse.post 'bookmarks', data, (json) ->
    console.log("Saved to parse", json)
    chrome.bookmarks.update(key, {title: json.objectId})
    localStorage[json.objectId] = JSON.stringify(data)


pinThisTab = ->
  chrome.tabs.getCurrent (tab) ->
    chrome.tabs.update tab.id, {'pinned': true}


pinnedOnClick = (element) ->
  if element.which == 1 && !element.metaKey && !element.shiftKey
    # We have a normal click, pin this tab
    pinThisTab()
    return

  # Mod-click or middle, don't lose focus or kill this tab
  chrome.tabs.create
    'pinned': true
    'selected': false
    'url': $(this).attr("href")

  return false


renderLinks = (data) ->
  template = Handlebars.compile($("#links-template").html())
  html     = template({rows: data})
  $('#links').html html
  $("a[data-pinned='true']").click pinnedOnClick


$('#purge-storage').click ->
  localStorage.clear()
  return false


$('#settings-toggle').click ->
  $('.settings').toggle()
  return false


chrome.storage.sync.get null, (data) ->
  console.log("Sync get", data)
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
        butt = new Button bookmark
        li = butt.li
        link = butt.link
        color_select = butt.color_select
        pin_check = butt.pin_check

        row.append li


        color_select.change ->
          val = $(this).val()
          link.attr('class', val)

          settings = new Settings bookmark
          settings.save 'color', val


        pin_check.attr('checked', syncdata["pinned-#{bookmark.url}"])
        pin_check.change ->
          checked = $(this).attr('checked') == 'checked'
          link.data('pinned', checked)

          settings = new Settings bookmark
          settings.save 'pinned', checked


        injectBookmark(bookmark)


