//on load
$(document).on('ContentLoad', function() {
  //select the first tab
  select_first_tab();
  $(document).on('click', '.nav-tabs a[data-toggle="tab"]', function() {
    select_first_tab();
  });
  // expend inner form fields
  $('.tabs-left .col-md-4')
    .removeClass('col-md-4')
    .addClass('col-md-8');
  //remove variable click event
  $(document).on('click', '.smart-var-tabs .close', function() {
    remove_node(this);
  });
  fill_in_matchers();
  $('.matchers')
    .parents('form')
    .on('submit', function() {
      build_match();
    });
  $('.matcher_key').select2('destroy');
});

function select_first_tab() {
  var pills = $('.lookup-keys-container:visible .smart-var-tabs li:visible');
  if (pills.length > 0 && pills.find('.tab-error:visible').length == 0) {
    pills
      .find('a:visible')
      .first()
      .click();
  }
}

function remove_node(item) {
  $(
    $(item)
      .parent('a')
      .attr('href')
  )
    .children('.btn-danger')
    .click();
}

function fix_template_context(content, context) {
  // context will be something like this for a brand new form:
  // project[tasks_attributes][new_1255929127459][assignments_attributes][new_1255929128105]
  // or for an edit form:
  // project[tasks_attributes][0][assignments_attributes][1]
  if (context) {
    var parent_names = context.match(/[a-z_]+_attributes/g) || [];
    var parent_ids = context.match(/(new_)?[0-9]+/g) || [];

    for (var i = 0; i < parent_names.length; i++) {
      if (parent_ids[i]) {
        content = content.replace(
          new RegExp('(_' + parent_names[i] + ')_.+?_', 'g'),
          '$1_' + parent_ids[i] + '_'
        );

        content = content.replace(
          new RegExp('(\\[' + parent_names[i] + '\\])\\[.+?\\]', 'g'),
          '$1[' + parent_ids[i] + ']'
        );
      }
    }
  }

  return content;
}

function fix_template_names(content, assoc, new_id) {
  var regexp = new RegExp('new_' + assoc, 'g');
  return content.replace(regexp, new_id);
}

function add_child_node(item) {
  // Setup
  var assoc = $(item).attr('data-association'); // Name of child
  var template_class = '.' + assoc + '_fields_template';
  var content = $(item)
    .parent()
    .find(template_class)
    .html(); // Fields template
  if (content == undefined) {
    content = $(template_class).html();
  }
  // Make the context correct by replacing new_<parents> with the generated ID
  // of each of the parent objects
  var context = (
    $(item)
      .closest('.fields')
      .find('input:first')
      .attr('name') || ''
  ).replace(new RegExp('[[a-z]+]$'), '');
  content = fix_template_context(content, context);
  var new_id = new Date().getTime();
  content = fix_template_names(content, assoc, new_id);
  var field = '';
  if (assoc == 'lookup_values') {
    field = $(item)
      .parent()
      .find('tbody')
      .first()
      .append($(content).find('tr'));
    $(item)
      .parent()
      .find('table')
      .removeClass('hidden');
  } else {
    field = $(content).insertBefore($(item));
  }
  $(item)
    .closest('form')
    .trigger({ type: 'nested:fieldAdded', field: field });
  $('a[rel="popover"]').popover();
  $('a[rel="twipsy"]').tooltip();
  activate_select2($(field).not('.matcher_key'));
  return new_id;
}

function remove_child_node(item) {
  var hidden_field = $(item).prev('input[type=hidden]')[0];
  if (hidden_field) {
    hidden_field.value = '1';
  }

  $(item)
    .closest('.fields')
    .hide();
  $(item)
    .closest('form')
    .trigger('nested:fieldRemoved');
  return false;
}

function delete_child_node(item) {
  $(item)
    .closest('.fields')
    .remove();
  $(item)
    .closest('form')
    .trigger('nested:fieldRemoved');
  return false;
}

function toggleOverrideValue(item) {
  var override = $(item).is(':checked');
  var fields = $(item).closest('.fields');
  var fields_to_disable = fields.find(
    "[name$='[required]'],[id$='_validator_type'],[name$='[omit]'],[name$='[hidden_value]'],[name$='[parameter_type]']"
  );
  var omit = $(item)
    .closest('fieldset')
    .find("[id$='omit']")
    .is(':checked');
  var default_value_field = fields.find("[id$='_default_value']");
  var pill_icon = $('#pill_' + fields[0].id + ' i');
  var override_value_div = fields.find("[id$='lookup_key_override_value']");

  fields_to_disable.prop('disabled', !override);
  default_value_field.prop('disabled', !override || omit);
  override ? pill_icon.addClass('fa-flag') : pill_icon.removeClass('fa-flag');
  override_value_div.toggle(override);
}

function changeCheckboxEnabledStatus(checkbox, shouldEnable) {
  if (shouldEnable) {
    $(checkbox).attr('disabled', null);
  } else {
    $(checkbox).attr('checked', false);
    $(checkbox).attr('disabled', 'disabled');
  }
}

function keyTypeChange(item) {
  var reloadedItem = $(item);
  var keyType = reloadedItem.val();
  var fields = reloadedItem.closest('.fields');
  var mergeOverrides = fields.find("[id$='_merge_overrides']");
  var avoidDuplicates = fields.find("[id$='_avoid_duplicates']");
  var mergeDefault = fields.find("[id$='_merge_default']");
  var validators = fields.find("[id^='optional_input_validators']");

  changeCheckboxEnabledStatus(
    mergeOverrides,
    keyType == 'array' || keyType == 'hash'
  );
  var mergeOverrideChecked = $(mergeOverrides).attr('checked') == 'checked';
  changeCheckboxEnabledStatus(
    avoidDuplicates,
    keyType == 'array' && mergeOverrideChecked
  );
  changeCheckboxEnabledStatus(mergeDefault, mergeOverrideChecked);
  validators.collapse('show');
  validators
    .parent()
    .find('legend')
    .removeClass('collapsed');
}

function mergeOverridesChanged(item) {
  var fields = $(item).closest('.fields');
  var keyType = fields.find("[id$='_parameter_type']").val();
  var avoidDuplicates = fields.find("[id$='_avoid_duplicates']");
  var mergeDefault = fields.find("[id$='_merge_default']");
  changeCheckboxEnabledStatus(
    avoidDuplicates,
    keyType == 'array' && item.checked
  );
  changeCheckboxEnabledStatus(mergeDefault, item.checked);
}

function toggleOmitValue(item, value_field) {
  var omit = $(item).is(':checked');
  $(item)
    .closest('.fields')
    .find('[id$=' + value_field + ']')
    .prop('disabled', omit);
}

function filterByEnvironment(item) {
  if ($(item).val() == '') {
    $('ul.smart-var-tabs li[data-used-environments] a').removeClass('hidden');
    return;
  }
  var selected = $(item)
    .find('option:selected')
    .text();
  $('ul.smart-var-tabs li[data-used-environments] a').addClass('hidden');
  $(
    'ul.smart-var-tabs li[data-used-environments*="' + selected + '"] a'
  ).removeClass('hidden');
}

function filterByClassParam(item) {
  var term = $(item)
    .val()
    .trim();
  if (term.length > 0) {
    $('ul.smart-var-tabs li[data-used-environments]')
      .removeClass('search-marker')
      .addClass('hidden');
    $(
      'ul.smart-var-tabs li[data-used-environments] a[href*=' +
        term +
        ']:not(.selected-marker)'
    )
      .parent()
      .addClass('search-marker')
      .removeClass('hidden');
  } else {
    $('ul.smart-var-tabs li[data-used-environments]:not(.selected-marker)')
      .addClass('search-marker')
      .removeClass('hidden');
  }
  return false;
}

function validatorTypeSelected(item) {
  var validatorType = $(item).val();
  var validator_rule_field = $(item)
    .closest('.fields')
    .find("[id$='_validator_rule']");
  validator_rule_field.attr(
    'disabled',
    validatorType == '' ? 'disabled' : null
  );
}

var KEY_DELM = ',';
var EQ_DELM = '=';

function match_to_key_value(match) {
  var regex = new RegExp('[' + KEY_DELM + EQ_DELM + ']');

  var keys = [],
    values = [],
    split_matcher = match.replace(/(\s+,) | (,\s+)/g, '').split(regex);

  $.each(split_matcher, function(index, value) {
    if (index % 2 === 0) {
      keys.push(value);
    } else {
      values.push(value);
    }
  });

  return [keys.join(KEY_DELM), values.join(KEY_DELM)];
}

function key_value_to_match(keys, values) {
  var match = '';
  keys.split(KEY_DELM).forEach(function(el, index) {
    match += el + EQ_DELM + values.split(KEY_DELM)[index] + KEY_DELM;
  });

  return match.slice(0, -1);
}

function fill_in_matchers() {
  $('.matchers').each(function() {
    var matcher = $(this);
    var match = matcher.find('.match').val();
    var matcher_key = matcher.find('.matcher_key');
    var matcher_value = matcher.find('.matcher_value');
    var order = matcher
      .closest('.matcher-parent')
      .find('#order')
      .val()
      .split('\n');
    matcher_key.empty();
    matcher_key.append('<option></option>');
    $.each(order, function(index, value) {
      matcher_key.append(
        $('<option>', { value: _.escape(value), html: _.escape(value) })
      );
    });
    if (match) {
      var key_value = match_to_key_value(match);
      matcher_key
        .find("option[value='" + key_value[0] + "']")
        .attr('selected', 'selected');
      matcher_value.val(key_value[1]);
    }

    $(matcher_value).data('initialValue', matcher_value.val());
    $(matcher_key).data('initialValue', matcher_key.find(":selected").text());

  });

  $('.input-group textarea[data-property="value"]').each(function(idx, element) {
    $(element).data('initialValue', $(element).val());
  });
}

function build_match() {
  $('.matchers').each(function() {
    var match = $(this).find('.match');
    var matcher_key = $(this).find('.matcher_key');
    var matcher_value = $(this).find('.matcher_value');
    match.val(key_value_to_match(matcher_key.val(), matcher_value.val()));
  });
}

function toggle_lookupkey_hidden(checkbox) {
  var default_value = $(
    '#' + checkbox.id.replace(/hidden_value$/, 'default_value')
  );
  var lookup_values = $(checkbox)
    .closest('.fields')
    .find('.lookup_values [id$="value"]');
  toggle_value_hidden(default_value);
  lookup_values.each(function() {
    toggle_value_hidden($(this));
  });
}

function toggle_value_hidden(target) {
  var shown = !target.hasClass('masked-input');
  target
    .closest('tr')
    .find('.set_hidden_value')
    .prop('checked', shown);
  target.toggleClass('masked-input');
}

function input_group_hidden(btn) {
  target = $(btn)
    .closest('.input-group')
    .find('textarea, input');
  toggle_value_hidden(target);
  $(btn)
    .hide()
    .siblings('.btn-hide')
    .show();
}
