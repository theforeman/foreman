function loadImages() {
  var item = $('#image_uuid');
  var url = item.data('url');
  var selected = item.data('selected');

  item.indicator_show();
  foreman.tools.showSpinner();
  item.attr("disabled", true);

  $.ajax({
    type: 'get',
    url: url,
    complete: function() {
      foreman.tools.hideSpinner();
      item.indicator_hide();
    },
    error: function(jqXHR, status, error) {
      setFieldError($(item), Jed.sprintf(__('Error loading images: %s'), error));
    },
    success: function(response) {
      item.empty();
      $.each(response, function(key, image) {
        var name = image.name;
        var uuid = image.uuid;
        var option = $('<option>').text(name).val(uuid);
        if (uuid == selected) {
          option.attr('selected', 'selected');
        }
        option.appendTo(item);
      });

      activate_select2(item.closest('form'));
      item.attr("disabled", false);
    }
  })
}

$(document).on('ContentLoad', function(){loadImages()});

function setFieldError(field, text) {
  var form_group = field.parents(".form-group").first();
  form_group.addClass("has-error");
  var help_block = form_group.children(".help-block").first();
  var span = $( document.createElement('span') );
  span.addClass("error-message").html(text);
  help_block.prepend(span);
};
