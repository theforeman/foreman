function filter_puppet_classes(item){
  var term = $(item).val().trim();
  var class_elems = $('.available_classes').find('.puppetclass_group, .puppetclass');
  if (term.length > 0) {
    class_elems.hide().has('[data-class-name*="'+term+'"]').show();
  } else {
    class_elems.show();
  }
}

function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  $(item).tooltip('hide');
  var content = $(item).closest('li').clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='" + type +"_puppetclass_ids_' name='" + type +"[puppetclass_ids][]' type='hidden' value=" +id+ ">");

  var link = content.children('a');
  var links = content.find('a');

  links.attr('onclick', 'remove_puppet_class(this)');
  links.attr('data-original-title', tfm.i18n.sprintf(__('Click to remove %s'), link.data("class-name")));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign').addClass('glyphicon-minus-sign');

  $('#selected_classes').append(content);

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).addClass('selected-marker').hide();
  findElementsForRemoveIcon($("#puppetclass_"+ id));
  // trigger load_puppet_class_parameters in host_edit.js which is fired by custom event handler called 'AddedClass'
  $(document.body).trigger('AddedClass', link);
}

function add_group_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  $(item).tooltip('hide');
  var content = $(item).closest('li').clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.children('span').tooltip();
  content.val('');

  var link = content.children('a');
  var links = content.find('a');
  links.attr('onclick', '');
  links.attr('data-original-title', __('belongs to config group'));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign');

  $('#selected_classes').append(content);

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).addClass('selected-marker').hide();

  // trigger load_puppet_class_parameters in host_edit.js which is fired by custom event handler called 'AddedClass'
  $(document.body).trigger('AddedClass', link);
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id).removeClass('selected-marker').show();
  $('#puppetclass_' + id).parent().prev().find('i').show();
  $('#puppetclass_' + id).closest('.puppetclass_group').show();
  $('#selected_puppetclass_' + id).children('a').tooltip('hide');
  $('#selected_puppetclass_' + id).remove();
  $('#puppetclass_' + id + '_params_loading').remove();
  $('[id^="puppetclass_' + id + '_params\\["]').remove();
  $('#params-tab').removeClass("tab-error");
  if ($("#params").find('.form-group.error').length > 0) $('#params-tab').addClass('tab-error');

  return false;
}

function addConfigGroup(item){
  var id = $(item).attr('data-group-id');
  var type = $(item).attr('data-type');
  var content = $(item).closest('li').clone();
  content.attr('id', 'selected_config_group_'+ id);
  content.append("<input id='config_group_ids' name=" + type + "[config_group_ids][] type='hidden' value=" +id+ ">");
  $("#selected_config_group_"+ id).show('highlight', 5000);
  $("#config_group_"+ id).addClass('selected-marker').hide();
  var link = content.children('a');
  var links = content.find('a');
  link.attr('onclick', 'removeConfigGroup(this)');
  link.attr('data-original-title', __('Click to remove config group'));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign').addClass('glyphicon-minus-sign');
  link.text(__(' Remove'));

  $('#selected_config_groups').append(content);
  $("#selected_config_group_"+ id).show('highlight', 5000);
  $("#config_group_"+ id).addClass('selected-marker').hide();

  var puppetclass_ids = $.parseJSON($(item).attr('data-puppetclass-ids'));
  var inherited_ids = $.parseJSON($('#inherited_ids').attr('data-inherited-puppetclass-ids'));

  $.each(puppetclass_ids, function(index,puppetclass_id) {
    var pc = $("li#puppetclass_" + puppetclass_id);
    var pc_link = $("a[data-class-id='" + puppetclass_id + "']");
    if ( (pc_link.length > 0) && (pc.length > 0) && ($.inArray(puppetclass_id, inherited_ids) == -1 ) ) {
      if (!($("#selected_puppetclass_"+ puppetclass_id).length > 0)) {
        add_group_puppet_class(pc_link);
      }
    }
  })
}

function removeConfigGroup(item){
  var id = $(item).attr('data-group-id');
  $('#config_group_' + id).removeClass('selected-marker').show();
  $('#selected_config_group_' + id).children('a').tooltip('hide');
  $('#selected_config_group_' + id).remove();

  var puppetclass_ids = $.parseJSON($(item).attr('data-puppetclass-ids'));
  var inherited_ids = $.parseJSON($('#inherited_ids').attr('data-inherited-puppetclass-ids'));

  $.each(puppetclass_ids, function(index,puppetclass_id){
    var pc = $('#selected_puppetclass_' + puppetclass_id);
    var pc_link = $("a[data-class-id='" + puppetclass_id + "']");
    if ( (pc_link.length > 0) && (pc.length > 0) && ($.inArray(puppetclass_id, inherited_ids) == -1 ) ) {
      remove_puppet_class(pc_link);
    }
  });
  return false;
}

function findElementsForRemoveIcon(element) {
  var clicked_element = element.parent().prev();
  var ul_id = '#' + element.parent().attr('id');
  removeIconIfEmpty(clicked_element, ul_id);
}

function expandClassList(clicked_element, toggle_element) {
  $(toggle_element).fadeToggle();
  clicked_element.find('i').toggleClass('glyphicon-plus glyphicon-minus');
  removeIconIfEmpty(clicked_element, toggle_element);
}

function removeIconIfEmpty(element, ul_id) {
  if ($(ul_id).children(':visible').length == 0) {
    element.find('i').hide();
  }
}
