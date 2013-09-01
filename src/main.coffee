
$('#purge-storage').click ->
  localStorage.clear()
  return false


$('#settings-toggle').click ->
  $('.settings').toggle()
  return false


if localStorage['cachedRows']
  console.log 'Loading cached page'
  cachedRows = $('<div>')
  cachedRows.attr 'id', 'cached-rows'
  cachedRows.html localStorage['cachedRows']
  $('body').append cachedRows
  $('#cached-rows a').click Button.onClick


Settings.initialize
  key: 'f0nb7har6a4aar0'
  ->
    console.log 'Loading dropbox data'
    # $('#cached-rows').remove()

    chrome.bookmarks.getTree (tree) ->
      mytree = null
      rows = ''
      $.each tree[0].children[1].children, (i,subtree) ->
        mytree = subtree if subtree.title == 'newtab'

      $.each mytree.children, (i,subtree) ->
        row = $('<ul>')
        $('body').append row

        $.each subtree.children, (i,bookmark) ->
          butt = new Button bookmark
          row.append butt.li

        rows += row[0].outerHTML

      localStorage['cachedRows'] = rows
      $('#cached-rows').remove()
