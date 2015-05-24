class @BrowserAction
  @clear: ->
    chrome.browserAction.setBadgeText text: ''

  @setSignin: ->
    chrome.browserAction.setTitle title: 'Signing in...'
    chrome.browserAction.setBadgeText text: '...'
    chrome.browserAction.setBadgeBackgroundColor color: '#00F'

  @setSyncing: ->
    chrome.browserAction.setTitle title: 'Syncing'
    chrome.browserAction.setBadgeText text: '<=>'
    chrome.browserAction.setBadgeBackgroundColor color: '#00F'

  @setNotSignedIn: ->
    chrome.browserAction.setTitle title: 'Not signed in'
    chrome.browserAction.setBadgeText text: '?'
    chrome.browserAction.setBadgeBackgroundColor color: '#FF0'

  @setError: (message) ->
    chrome.browserAction.setTitle title: message
    chrome.browserAction.setBadgeText text: '!'
    chrome.browserAction.setBadgeBackgroundColor color: '#F00'
