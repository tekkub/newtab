
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
        row.append butt.li

        injectBookmark(bookmark)


