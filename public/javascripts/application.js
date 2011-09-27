$(function() {
  $('.error').hide().each(function(index, item) {
    if ($('.errorExplanation').length == 0) {
      $.jnotify($(item).text(), { type: "error", sticky: true });
    }
  });

  $('.warning').hide().each(function(index, item) {
    $.jnotify($(item).text(), { type: "warning", sticky: true });
  });

  $('.notice').hide().each(function(index, item) {
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
  if($("#"+div)[0] == undefined)
  {
    var html = $('<div id= '+ div + ' class="fact_chart" ></div>').appendTo('body');
    $.getJSON(url, function(data) { pie_chart(div, data.name, data.values);
      html.dialog({
        width: 600,
        resizable: false,
        title: data.name + ' distribution',
        close: function(event, ui){
           $("#"+div).remove();
        }
      });
    });
  } else {$("#"+div).dialog("moveToTop");}
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
          [1, '#EDF6FC']
       ]}
    },
    credits: {
    enabled: false,
    },
    title: {
       text: title
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
    cancel      : 'Cancel',
    submit      : 'Save',
    indicator   : "<img src='../images/spinner.gif' />",
    tooltip     : 'Click to edit..',
    placeholder : 'Click to edit..',
    submitdata  : {authenticity_token: AUTH_TOKEN, format : "json"},
    onedit      : function(data) { $(this).removeClass("editable"); },
    callback    : function(value, settings) { $(this).addClass("editable"); },
    onsuccess   :  function(data) {
      var parsed = $.parseJSON(data);
      $(this).html(parsed[$(this).attr('name').split("[")[0]][$(this).attr('data-field')]);
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
      width: '100%',
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

});