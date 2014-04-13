function filter_puppet_classes(item){
  var term = $(item).val().trim();
  $('.puppetclass_group li.puppetclass.hide').addClass('hide-me');
  if (term.length > 0) {
    $('.puppetclass_group li.puppetclass').removeClass('filter-marker').hide();
    $('.puppetclass_group li.puppetclass:not(.hide-me, .selected-marker) span:contains('+term+')').parent('li').addClass('filter-marker').show();
  } else{
    $('.puppetclass_group li.puppetclass:not(.hide-me, .selected-marker)').addClass('filter-marker').show();
  }
  var groups = $('li.filter-marker').closest('.puppetclass_group');
  $('.puppetclass_group').hide();
  groups.show();
}

function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  $(item).tooltip('hide');
  var content = $(item).closest('li').clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='" + type +"_puppetclass_ids_' name='" + type +"[puppetclass_ids][]' type='hidden' value=" +id+ ">");
  content.children('span').tooltip();

  var link = content.children('a');
  var links = content.find('a');
  links.attr('onclick', 'remove_puppet_class(this)');
  links.attr('data-original-title', __('Click to undo adding this class'));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign').addClass('glyphicon-minus-sign');

  $('#selected_classes').append(content);

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).addClass('selected-marker').hide();

  // trigger load_puppet_class_parameters in host_edit.js which is fired by custom event handler called 'AddedClass'
  $(document.body).trigger('AddedClass', link);
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id).removeClass('selected-marker').show();
  $('#puppetclass_' + id).closest('.puppetclass_group').show();
  $('#selected_puppetclass_' + id).children('a').tooltip('hide');
  $('#selected_puppetclass_' + id).remove();
  $('#puppetclass_' + id + '_params_loading').remove();
  $('[id^="puppetclass_' + id + '_params\\["]').remove();
  $('#params-tab').removeClass("tab-error");
  if ($("#params").find('.form-group.error').length > 0) $('#params-tab').addClass('tab-error');

  return false;
}

