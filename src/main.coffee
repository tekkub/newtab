
Settings.initialize


$.parse.init
  app_id: "xUAcXfMivxbjqOhtLuX9e0Nz7zO0aL0ieq93swiN"
  rest_key: "tbVr6U9goimUx4m0LHE5B24MtibdCYqiTlSnKyk2"


$('#purge-storage').click ->
  localStorage.clear()
  return false


$('#settings-toggle').click ->
  $('.settings').toggle()
  return false


chrome.storage.sync.get null, (data) ->
  console.log("Sync get", data)

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

dropbox = new Dropbox.Client
  key: 'f0nb7har6a4aar0'

if dropbox.isAuthenticated()
  console.log 'Dropbox auth successful'
else
  console.log 'Dropbox not authed'
  dropbox.authenticate (error, client) ->
    if error
      alert "Error authenticating: #{error}"
      return false

    datastoreManager = dropbox.getDatastoreManager()
    datastoreManager.openDefaultDatastore (error, datastore) ->
      if error
        alert "Error opening default datastore: #{error}"
        return false
      console.log datastore
