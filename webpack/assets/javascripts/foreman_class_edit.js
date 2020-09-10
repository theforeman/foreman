/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-fade */
/* eslint-disable jquery/no-sizzle */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-trigger */
/* eslint-disable jquery/no-show */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-parent */
/* eslint-disable jquery/no-clone */
/* eslint-disable jquery/no-hide */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-in-array */
/* eslint-disable jquery/no-closest */

import $ from 'jquery';
import { sprintf, translate as __ } from './react_app/common/I18n';

export function filterPuppetClasses(item) {
  const term = $(item)
    .val()
    .trim();
  const classElems = $('.available_classes').find(
    '.puppetclass_group, .puppetclass'
  );
  if (term.length > 0) {
    classElems
      .hide()
      .has(`[data-class-name*="${term}"]`)
      .show();
  } else {
    classElems.show();
  }
}

export function addPuppetClass(item) {
  const id = $(item).attr('data-class-id');
  const type = $(item).attr('data-type');
  $(item).tooltip('hide');
  const content = $(item)
    .closest('li')
    .clone();
  content.attr('id', `selected_puppetclass_${id}`);
  content.append(
    `<input id='${type}_puppetclass_ids_' name='${type}[puppetclass_ids][]' type='hidden' value=${id}>`
  );

  const link = content.children('a');
  const links = content.find('a');

  links.attr('onclick', 'tfm.classEditor.removePuppetClass(this)');
  links.attr(
    'data-original-title',
    sprintf(__('Click to remove %s'), link.data('class-name'))
  );
  links.tooltip();
  link.removeClass('glyphicon-plus-sign').addClass('glyphicon-minus-sign');

  $('#selected_classes').append(content);

  $(`#selected_puppetclass_${id}`).show('highlight', 5000);
  $(`#puppetclass_${id}`)
    .addClass('selected-marker')
    .hide();
  findElementsForRemoveIcon($(`#puppetclass_${id}`));
  // trigger load_puppet_class_parameters in host_edit.js which is fired by custom event handler called 'AddedClass'
  $(document.body).trigger('AddedClass', link);
}

function addGroupPuppetClass(item) {
  const id = $(item).attr('data-class-id');
  $(item).tooltip('hide');
  const content = $(item)
    .closest('li')
    .clone();
  content.attr('id', `selected_puppetclass_${id}`);
  content.children('span').tooltip();
  content.val('');

  const link = content.children('a');
  const links = content.find('a');
  links.attr('onclick', '');
  links.attr('data-original-title', __('belongs to config group'));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign');

  $('#selected_classes').append(content);

  $(`#selected_puppetclass_${id}`).show('highlight', 5000);
  $(`#puppetclass_${id}`)
    .addClass('selected-marker')
    .hide();

  // trigger load_puppet_class_parameters in host_edit.js which is fired by custom event handler called 'AddedClass'
  $(document.body).trigger('AddedClass', link);
}

export function removePuppetClass(item) {
  const id = $(item).attr('data-class-id');
  $(`#puppetclass_${id}`)
    .removeClass('selected-marker')
    .show();
  $(`#puppetclass_${id}`)
    .parent()
    .prev()
    .find('i')
    .show();
  $(`#puppetclass_${id}`)
    .closest('.puppetclass_group')
    .show();
  $(`#selected_puppetclass_${id}`)
    .children('a')
    .tooltip('hide');
  $(`#selected_puppetclass_${id}`).remove();
  $(`#puppetclass_${id}_params_loading`).remove();
  $(`[id^="puppetclass_${id}_params\\["]`).remove();
  $('#params-tab').removeClass('tab-error');
  if ($('#params').find('.form-group.error').length > 0)
    $('#params-tab').addClass('tab-error');

  return false;
}

export function addConfigGroup(item) {
  const id = $(item).attr('data-group-id');
  const type = $(item).attr('data-type');
  const content = $(item)
    .closest('li')
    .clone();
  content.attr('id', `selected_config_group_${id}`);
  content.append(
    `<input id='config_group_ids' name=${type}[config_group_ids][] type='hidden' value=${id}>`
  );
  $(`#selected_config_group_${id}`).show('highlight', 5000);
  $(`#config_group_${id}`)
    .addClass('selected-marker')
    .hide();
  const link = content.children('a');
  const links = content.find('a');
  link.attr('onclick', 'tfm.classEditor.removeConfigGroup(this)');
  link.attr('data-original-title', __('Click to remove config group'));
  links.tooltip();
  link.removeClass('glyphicon-plus-sign').addClass('glyphicon-minus-sign');
  link.text(__(' Remove'));

  $('#selected_config_groups').append(content);
  $(`#selected_config_group_${id}`).show('highlight', 5000);
  $(`#config_group_${id}`)
    .addClass('selected-marker')
    .hide();

  const puppetclassIds = $.parseJSON($(item).attr('data-puppetclass-ids'));
  const inheritedIds = $.parseJSON(
    $('#inherited_ids').attr('data-inherited-puppetclass-ids')
  );

  $.each(puppetclassIds, (index, puppetclassId) => {
    const pc = $(`li#puppetclass_${puppetclassId}`);
    const pcLink = $(`a[data-class-id='${puppetclassId}']`);
    if (
      pcLink.length > 0 &&
      pc.length > 0 &&
      $.inArray(puppetclassId, inheritedIds) === -1
    ) {
      if (!($(`#selected_puppetclass_${puppetclassId}`).length > 0)) {
        addGroupPuppetClass(pcLink);
      }
    }
  });
}

export function removeConfigGroup(item) {
  const id = $(item).attr('data-group-id');
  $(`#config_group_${id}`)
    .removeClass('selected-marker')
    .show();
  $(`#selected_config_group_${id}`)
    .children('a')
    .tooltip('hide');
  $(`#selected_config_group_${id}`).remove();

  const puppetclassIds = $.parseJSON($(item).attr('data-puppetclass-ids'));
  const inheritedIds = $.parseJSON(
    $('#inherited_ids').attr('data-inherited-puppetclass-ids')
  );

  $.each(puppetclassIds, (index, puppetclassId) => {
    const pc = $(`#selected_puppetclass_${puppetclassId}`);
    const pcLink = $(`a[data-class-id='${puppetclassId}']`);
    if (
      pcLink.length > 0 &&
      pc.length > 0 &&
      $.inArray(puppetclassId, inheritedIds) === -1
    ) {
      removePuppetClass(pcLink);
    }
  });
  return false;
}

function findElementsForRemoveIcon(element) {
  const clickedElement = element.parent().prev();
  const ulId = `#${element.parent().attr('id')}`;
  removeIconIfEmpty(clickedElement, ulId);
}

export function expandClassList(clickedElement, toggleElement) {
  $(toggleElement).fadeToggle();
  clickedElement.find('i').toggleClass('glyphicon-plus glyphicon-minus');
  removeIconIfEmpty(clickedElement, toggleElement);
}

function removeIconIfEmpty(element, ulId) {
  if ($(ulId).children(':visible').length === 0) {
    element.find('i').hide();
  }
}
