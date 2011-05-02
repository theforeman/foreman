// Settings drop-down
$(function() {
  // in case the user doesn't have access to settings return
  if ( $("#settings_list").position() == undefined) return;

  $("#settings_list").hide();
  $("#settings_dropdown").autocomplete({
    source: function(request, response) {
      response(
          $("#settings_list").children("option").map(
              function(item) {
                return { label: this.text , value: this.value };
              })
          );
    },
    minLength: 0,
    delay: 0,
    select: function(event, ui) {
      window.location.href = ui.item.value;
    }
  }).data("autocomplete")._renderItem = function(ul, item) {
    return $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a href=" + item.value + ">" + item.label + "</a>")
        .appendTo(ul);
  };
  // toggle drop-down.
  $('#settings_dropdown').click(function() {
    if ($(this).autocomplete("widget").is(":visible")) {
      $(this).autocomplete("close");
      return;
    }
    $(this).autocomplete('search', '');
  });
  // close drop-down when mouse leave the widget.
  $('#settings_dropdown').autocomplete("widget").hover(function() {
  },
      function() {
        if ($(this).is(":visible")) {
          $('#settings_dropdown').autocomplete("widget").slideUp('fast');
        }
      });
});

// Bookmarks sub-menu
$(function() {
  $(".bookmarks-list").hide();
  var mainMenu = $("#menu1 li span").parent().parent();

  mainMenu.autocomplete({
    source: function(request, response) {
      response(
          $(this.element).children("ul").children("li").map(
              function() {
                var bookmark = $(this).children("a")[0];
                return { label: bookmark.text , value: bookmark.href };
              })
          )
    },
    minLength: 0,
    delay: 0,
    select:  function(event, ui) {
      window.location.href = ui.item.value;
    }
  })
  mainMenu.each(function (i) {
    $(this).autocomplete("widget").addClass("menu-dropdown")
  });

  // toggle sub-menu
  $("#menu1 li span").click(function() {
    var currentMenu = $(this).parent().parent();
    if (currentMenu.autocomplete("widget").is(":visible")) {
      currentMenu.autocomplete("close");
      return false;
    }
    mainMenu.autocomplete("close");
    currentMenu.autocomplete('search', '');
    return false;
  });

  $(".menu-dropdown").hover(function() {
  },
      function() {
        if ($(this).is(":visible")) {
          $(this).slideUp('fast');
        }
      });


});

// new bookmark button and dialog
$(function() {
  $("#bookmark").button({
    icons: { primary: "ui-icon-star" },
    text: false
  }).click(function() {
    var query = encodeURI($("#search").val());
    if (query.length == 0) {
      return false;
    }
    $('<div />').appendTo('body').load($(this).attr('href') + '&query=' + query + ' form').dialog({
      title: $(this).text(),
      width: 450,
      resizable: false,
      modal: true
    })
    return false;
  }),
      $("#submit_search").button({
        icons: { primary: "ui-icon-search" }
      });
});

// menu animation
$(function() {
  var $el, leftPos, newWidth, $mainNav = $("#menu1");

  $mainNav.append("<li id='magic-line'></li>");

  var $magicLine = $("#magic-line");
  var currPage = $(".current_page_item").find("a");
  if (currPage.position() == undefined) {
    currPage = $("#settings_dropdown");
    currPage.addClass('current_page_item');
  }
  $magicLine
      .width(currPage.parent().width() - 8)
      .css("left", currPage.position().left )
      .data("origLeft", $magicLine.position().left)
      .data("origWidth", $magicLine.width());

  $("#menu1 li").find("a").hover(function() {
    $el = $(this);
    leftPos = $el.position().left ;
    newWidth = $el.parent().width() - 8;

    $magicLine.stop().animate({
      left: leftPos,
      width: newWidth
    });
  }, function() {
    $magicLine.stop().animate({
      left: $magicLine.data("origLeft"),
      width: $magicLine.data("origWidth")
    });
  });
});

