// Generated by CoffeeScript 1.3.3
(function() {
  var colors, getBookmarkData, injectBookmark, loadingParse, renderLinks, saveBookmarkData, syncdata;

  if (localStorage['db-version'] !== '2') {
    console.log('Resetting localStorage');
    localStorage.clear();
    localStorage['db-version'] = '2';
  }

  syncdata = null;

  loadingParse = false;

  colors = ['silver', 'black', 'purple', 'blue', 'green', 'yellow', 'orange', 'red', 'pink'];

  $.parse.init({
    app_id: "xUAcXfMivxbjqOhtLuX9e0Nz7zO0aL0ieq93swiN",
    rest_key: "tbVr6U9goimUx4m0LHE5B24MtibdCYqiTlSnKyk2"
  });

  injectBookmark = function(bookmark) {
    var img_div, li, link, setting_div, settings;
    settings = getBookmarkData(bookmark);
    li = $("#bookmark-" + bookmark.id);
    link = li.children('a');
    link.data('bookmarkid', bookmark.id).attr('href', bookmark.url).attr('class', settings["color"]).data('pinned', settings["pinned"]);
    img_div = link.children('div');
    img_div.attr('class', "link-image").css('background', "url(" + settings["rawimg"] + ")").css('background-size', "100%");
    setting_div = li.children('div.settings');
    setting_div.children('select').val(settings['color']);
    return setting_div.children('label.pinlabel').children('input').attr('checked', settings["pinned"]);
  };

  getBookmarkData = function(bookmark) {
    var data, default_data, hash, raw;
    hash = bookmark.title;
    default_data = {
      'id': bookmark.id,
      'link': bookmark.url
    };
    if (hash === '') {
      return default_data;
    }
    raw = localStorage[hash];
    if (raw) {
      data = JSON.parse(raw);
      data['id'] = bookmark.id;
      return data;
    } else {
      if (!loadingParse) {
        loadingParse = true;
        $.parse.get('bookmarks', function(data) {
          var entry, _i, _len, _ref, _results;
          _ref = data.results;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            entry = _ref[_i];
            console.log("Parse data received " + entry.objectId, entry);
            localStorage[entry.objectId] = JSON.stringify(entry);
            injectBookmark(bookmark);
            _results.push(loadingParse = false);
          }
          return _results;
        });
      }
      return default_data;
    }
  };

  saveBookmarkData = function(key, data) {
    data.id = null;
    data.objectId = null;
    console.log("New data", data);
    return $.parse.post('bookmarks', data, function(json) {
      console.log("Saved to parse", json);
      chrome.bookmarks.update(key, {
        title: json.objectId
      });
      return localStorage[json.objectId] = JSON.stringify(data);
    });
  };

  renderLinks = function(data) {
    var html, template;
    template = Handlebars.compile($("#links-template").html());
    html = template({
      rows: data
    });
    $('#links').html(html);
    return $("a[data-pinned='true']").click(function(e) {
      if (e.which === 1 && !e.metaKey && !e.shiftKey) {
        chrome.tabs.getCurrent(function(tab) {
          return chrome.tabs.update(tab.id, {
            'pinned': true
          });
        });
        return;
      }
      chrome.tabs.create({
        'pinned': true,
        'selected': false,
        'url': $(this).attr("href")
      });
      return false;
    });
  };

  $('#purge-storage').click(function() {
    localStorage.clear();
    return false;
  });

  $('#settings-toggle').click(function() {
    $('.settings').toggle();
    return false;
  });

  chrome.storage.sync.get(null, function(data) {
    var newdata;
    console.log("Sync get", data);
    syncdata = data;
    newdata = [];
    return chrome.bookmarks.getTree(function(tree) {
      var mytree;
      mytree = null;
      $.each(tree[0].children[1].children, function(i, subtree) {
        if (subtree.title === 'newtab') {
          return mytree = subtree;
        }
      });
      return $.each(mytree.children, function(i, subtree) {
        var row;
        row = $('<ul>');
        $('body').append(row);
        return $.each(subtree.children, function(i, bookmark) {
          var color, color_select, img_div, key, li, link, opt, pin_check, pin_label, setting_div, _i, _len;
          li = $('<li>').attr('id', "bookmark-" + bookmark.id);
          row.append(li);
          link = $('<a>').click(function(e) {
            if (link.data('pinned')) {
              if (e.which === 1 && !e.metaKey && !e.shiftKey) {
                chrome.tabs.getCurrent(function(tab) {
                  return chrome.tabs.update(tab.id, {
                    'pinned': true
                  });
                });
                return;
              }
              chrome.tabs.create({
                'pinned': true,
                'selected': false,
                'url': $(this).attr("href")
              });
              return false;
            }
          });
          li.append(link);
          key = bookmark.id;
          img_div = $('<div>').attr('class', 'link-image').bind('drop', function(ev) {
            var dt, file, reader, target_img;
            dt = ev.originalEvent.dataTransfer;
            target_img = $(ev.target);
            target_img.removeClass('dragover');
            if (dt.types[0] !== "Files") {
              return true;
            }
            if (dt.files.length !== 1) {
              ev.stopPropagation();
              return false;
            }
            file = dt.files[0];
            if (file.type.indexOf("image") === 0) {
              reader = new FileReader();
              reader.onload = function(e) {
                var imgsrc;
                imgsrc = e.target.result;
                target_img.css("background", "url(" + imgsrc + ")").css('background-size', "100%");
                return chrome.bookmarks.get(key, function(bookmark) {
                  var bookmark_data;
                  bookmark_data = getBookmarkData(bookmark[0]);
                  bookmark_data['rawimg'] = imgsrc;
                  return saveBookmarkData(key, bookmark_data);
                });
              };
              reader.readAsDataURL(file);
            }
            ev.stopPropagation();
            return false;
          }).bind('dragenter', function(ev) {
            $(ev.target).addClass('dragover');
            return false;
          }).bind('dragleave', function(ev) {
            $(ev.target).removeClass('dragover');
            return false;
          }).bind('dragover', function(ev) {
            return false;
          });
          link.append(img_div);
          setting_div = $('<div>').attr('class', 'settings');
          li.append(setting_div);
          color_select = $('<select>');
          setting_div.append(color_select);
          for (_i = 0, _len = colors.length; _i < _len; _i++) {
            color = colors[_i];
            opt = $('<option>').text(color);
            color_select.append(opt);
          }
          color_select.change(function() {
            var settings, val;
            val = $(this).val();
            link.attr('class', val);
            settings = getBookmarkData(bookmark);
            settings['color'] = val;
            return saveBookmarkData(bookmark.id, settings);
          });
          pin_label = $('<label>').text('Pinned').attr('class', 'pinlabel');
          setting_div.append(pin_label);
          pin_check = $('<input>').attr('type', 'checkbox').attr('checked', syncdata["pinned-" + bookmark.url]).change(function() {
            var checked, settings;
            checked = $(this).attr('checked') === 'checked';
            link.data('pinned', checked);
            settings = getBookmarkData(bookmark);
            settings['pinned'] = checked;
            return saveBookmarkData(bookmark.id, settings);
          });
          pin_label.append(pin_check);
          return injectBookmark(bookmark);
        });
      });
    });
  });

}).call(this);
