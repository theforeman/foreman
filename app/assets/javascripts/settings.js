$(document).ready(function() {
  var common_settings = {
    method      : 'PUT',
    indicator   : spinner_placeholder(),
    tooltip     : __('Click to edit..'),
    placeholder : __('Click to edit..'),
    submitdata  : {authenticity_token: AUTH_TOKEN, format : "json"},
    onblur      : 'nothing',
    oneditcomplete : function(){
      onEnterEdit($(this).parents('.setting'))
    },
    callback: function(){
      onLeaveEdit($(this))
    },
    onreset : function(){
      onLeaveEdit($(this).parents('.setting'))
    },
    onsuccess   : function(data) {
      var parsed = $.parseJSON(data);
      var key = $(this).attr('name').split("[")[0];
      var val = $(this).attr('data-field');

      var editable_value = parsed[key][val];
      if ($.isArray(editable_value))
        editable_value = "[ "+editable_value.join(", ")+" ]";
      else
        editable_value = String(editable_value);

      $(this).html(editable_value);
    },
    onerror     : function(settings, original, xhr) {
      original.reset();
      var error = $.parseJSON(xhr.responseText)["errors"];
      $.jnotify(error, { type: "error", sticky: true });
    }
  };

  $('.edit_textfield').each(function() {
    var settings = {
      type : 'text',
      name : $(this).attr('name'),
      submit : __('Save'),
      cancel : __('Cancel'),
      width: '100%',
      height: '34px'
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
      submit : __('Save')
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });
});

function onEnterEdit(item){
  item.removeClass("editable");
  item.tooltip('destroy');
  item.find('input, select').addClass('form-group form-control');
  item.find('button').addClass('btn btn-default btn-sm');
  item.find('button[type="submit"]').addClass('btn-primary').css({'margin-right': '4px'})
}
function onLeaveEdit(item){
  item.addClass("editable");
  item.tooltip()
}
