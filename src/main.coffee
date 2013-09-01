
Settings.initialize
  key: 'f0nb7har6a4aar0'


$.parse.init
  app_id: "xUAcXfMivxbjqOhtLuX9e0Nz7zO0aL0ieq93swiN"
  rest_key: "tbVr6U9goimUx4m0LHE5B24MtibdCYqiTlSnKyk2"


$('#purge-storage').click ->
  localStorage.clear()
  return false


$('#settings-toggle').click ->
  $('.settings').toggle()
  return false


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
