$(function() {
  $('.flash.error').hide().each(function(index, item) {
    if ($('.alert-message.error.base').length == 0) {
      $.jnotify($(item).text(), { type: "error", sticky: true });
    }
  });

  $('.flash.warning').hide().each(function(index, item) {
    $.jnotify($(item).text(), { type: "warning", sticky: true });
  });

  $('.flash.notice').hide().each(function(index, item) {
    $.jnotify($(item).text(), { type: "success", sticky: false });
  });
});


function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).parent().before(content.replace(regexp, new_id));
}

function checkAll (id, checked) {
  $(id).find(":checkbox:not([disabled='disabled'])").attr('checked',checked)
}

function toggleCheckboxesBySelector(selector) {
  boxes = $(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) { if (boxes[i].checked == false) { all_checked = false; } }
  for (i = 0; i < boxes.length; i++) { boxes[i].checked = !all_checked; }
}

function toggleRowGroup(el) {
  var tr = $(el).closest('tr');
  var n = tr.next();
  tr.toggleClass('open');
  while (n != undefined && !n.hasClass('group')) {
    n.toggle();
    n = n.next();
  }
}

// allow opening new window for selected links
$(function() {
  $('a[rel="external"]').click( function() {
    window.open( $(this).attr('href') );
    return false;
  });
});

function template_info(div, url) {
  os_id = $("#host_operatingsystem_id :selected").attr("value");
  env_id = $("#host_environment_id :selected").attr("value");
  hostgroup_id = $("#host_hostgroup_id :selected").attr("value");

  $(div).html('<img src="/images/spinner.gif" alt="Wait" />');
  $(div).load(url + "?operatingsystem_id=" + os_id + "&hostgroup_id=" + hostgroup_id + "&environment_id=" + env_id,
      function(response, status, xhr) {
        if (status == "error") {
          $(div).html("<p>Sorry but no templates were configured.</p>");
        }
      });
}


function get_pie_chart(div, url) {
  if($("#"+div).length == 0)
  {
    $('body').append('<div id="' + div + '" class="modal fade"></div>');
    $("#"+div).append('<div class="modal-header"><a href="#" class="close">×</a><h3>Fact Chart</h3></div>')
              .append('<div id="' + div + '-body" class="fact_chart modal-body">Loading ...</div>');
    $("#"+div).modal('show');
    $.getJSON(url, function(data) {
      pie_chart(div+'-body', data.name, data.values);
    });
  } else {$("#"+div).modal('show');}
}

function pie_chart(div, title, data) {
  new Highcharts.Chart({
    chart: {
      renderTo: div,
      borderWidth: 0,
      backgroundColor: {
       linearGradient: [0, 0, 0, 200],
       stops: [
          [0, '#ffffff'],
          [1, '#EDEDED']
       ]}
    },
    credits: {
    enabled: false,
    },
    title: {
       text: title,
       style: {color: "#000000"}
    },
    tooltip: {
       formatter: function() {
          return '<b>'+ this.point.name +'</b>: '+ this.y;
       }
    },
    plotOptions: {
       pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
             enabled: true,
             formatter: function() {
                return '<b>'+ this.point.name +'</b>: '+ this.y;
             }
          }
       }
    },
     series: [{
       type: 'pie',
       name: '',
       data: data
    }]
  });
};

$(document).ready(function() {
  var common_settings = {
    method      : 'PUT',
    indicator   : "<img src='../images/spinner.gif' />",
    tooltip     : 'Click to edit..',
    placeholder : 'Click to edit..',
    submitdata  : {authenticity_token: AUTH_TOKEN, format : "json"},
    onedit      : function(data) { $(this).removeClass("editable"); },
    callback    : function(value, settings) { $(this).addClass("editable"); },
    onsuccess   :  function(data) {
      var parsed = $.parseJSON(data);
      var key = $(this).attr('name').split("[")[0]
      var val = $(this).attr('data-field');
      $(this).html(String(parsed[key][val]));
    },
    onerror     : function(settings, original, xhr) {
      original.reset();
      var error = $.parseJSON(xhr.responseText)["errors"]
      $.jnotify(error, { type: "error", sticky: true });
    }
  };

  $('.edit_textfield').each(function() {
    var settings = {
      type : 'text',
      name : $(this).attr('name'),
      width: '95%',
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });

  $('.edit_textarea').each(function() {
    var settings = {
      type : 'textarea',
      name : $(this).attr('name'),
      rows : 8,
      cols : 36
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });

  $('.edit_select').each(function() {
    var settings = {
      type : 'select',
      name : $(this).attr('name'),
      data : $(this).attr('select_values'),
      submit : 'Save',
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });


});

// adds buttons classes to all links
$(function(){
  $("#title_action a").addClass("btn");
  $(".table_action a").addClass("btn small");
});

$(function()
{
  magic_line("#menu" , 1);
  magic_line("#menu2", 0);
});

function magic_line(id, combo) {
    var $el, leftPos, newWidth, $mainNav = $(id);

    $mainNav.append("<li class='magic-line'></li>");
    var $magicLine = $(id + " .magic-line");

    $magicLine
        .width($(id +" .active").width() + $(id + " .active.dropdown").width() * combo)
        .css("left", $(".active").position().left)
        .data("origLeft", $magicLine.position().left)
        .data("origWidth", $magicLine.width());

    $(id + " li").hover(function() {
        $el = $(this);
        if ($el.parent().hasClass("dropdown-menu")){
          $el=$el.parent().parent();
        }
        leftPos = $el.position().left;
        newWidth = $el.width();
        if ($el.find("a").hasClass("narrow-right")){
          newWidth = newWidth + $(".dropdown").width() * combo;
        }
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
}

//add bookmark dialog
$(function()
{
  $('#bookmarks-modal .primary').click(function(){
    $("#bookmark_submit").click();
  });
  $('#bookmarks-modal .secondary').click(function(){
    $('#bookmarks-modal').modal('hide');
  });
  $("#bookmarks-modal").bind('shown', function () {
    var query = encodeURI($("#search").val());
    $("#bookmarks-modal .modal-body").append("<span id='loading'>Loading ...</span>");
    $("#bookmarks-modal .modal-body").load($("#bookmark").attr('href') + '&query=' + query + ' form',
        function(response, status, xhr) {
          $("#loading").hide();
          $("#bookmarks-modal .modal-body .btn").hide()
        });
  });

});

//
// highlight tabs with errors
$(function(){
  $(".tab-content").find(".clearfix.error").each(function() {
    // find each tab id
    var id = $(this).parentsUntil(".tab-content").attr("id");
    // now add a class to that tab
    $("a[href=#"+id+"]").addClass("tab_error");
  })
});

$(function () {
  $('a[rel="popover"]').popover({
    html: true
  });
  $('a[rel="twipsy"]').twipsy();
});
