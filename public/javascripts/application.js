function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
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


// Settings edit
function edit_setting(name, url) {
  var html = $('<div></div>').appendTo('body').load(url + " #content");
  html.dialog({
    modal: true,
    title: "Editing " + name,
    width: 700,
    height: 250,
    close: function(event, ui) {},
    buttons: [
      {
        text: "OK",
        click: function() {
            $("form").submit();
            $( this ).dialog( "close" );
        },
      },{
        text: "Cancel",
        click: function() {
          $( this ).dialog( "close" );
        }
      }
    ]
  });

  return false;
}
