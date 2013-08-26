class Button
  constructor: (@bookmark) ->
    @li = $('<li>')
    @li.attr('id', "bookmark-#{bookmark.id}")
    @render()

  render: ->
    link = $('<a>')
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

    @li.append link

  getListItem: ->
    return @li
