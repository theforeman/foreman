//on load
$(function() {
  //select the first tab
  select_first_tab();
  $(document).on('click', '.nav-tabs a[data-toggle="tab"]', function(){select_first_tab();});
  // expend inner form fields
  $('.tabs-left .col-md-4').removeClass('col-md-4').addClass('col-md-8')
  //remove variable click event
  $(document).on('click', '.smart-var-tabs li a span', function(){ remove_node(this);});
})

function select_first_tab(){
  var pills = $('.lookup-keys-container:visible .smart-var-tabs li:visible');
  if (pills.length > 0 && pills.find('.tab-error:visible').length == 0){
    pills.find('a:visible').first().click();
  }
}

function remove_node(item){
  $($(item).parent("a").attr("href")).children('.btn-danger').click();
}

function fix_template_context(content, context) {

  // context will be something like this for a brand new form:
  // project[tasks_attributes][new_1255929127459][assignments_attributes][new_1255929128105]
  // or for an edit form:
  // project[tasks_attributes][0][assignments_attributes][1]
  if(context) {
    var parent_names = context.match(/[a-z_]+_attributes/g) || [];
    var parent_ids   = context.match(/(new_)?[0-9]+/g) || [];

    for(var i = 0; i < parent_names.length; i++) {
      if(parent_ids[i]) {
        content = content.replace(
          new RegExp('(_' + parent_names[i] + ')_.+?_', 'g'),
          '$1_' + parent_ids[i] + '_');

        content = content.replace(
          new RegExp('(\\[' + parent_names[i] + '\\])\\[.+?\\]', 'g'),
          '$1[' + parent_ids[i] + ']');
      }
    }
  }

  return content;
}


function fix_template_names(content, assoc, new_id) {
  var regexp  = new RegExp('new_' + assoc, 'g');
  return content.replace(regexp, new_id);
}

function add_child_node(item) {
    // Setup
    var assoc   = $(item).attr('data-association');           // Name of child
    var template_class = '.' + assoc + '_fields_template';
    var content = $(item).parent().find(template_class).html(); // Fields template
    if (content == undefined) {content = $(template_class).html()};

    // Make the context correct by replacing new_<parents> with the generated ID
    // of each of the parent objects
    var context = ($(item).closest('.fields').find('input:first').attr('name') || '').replace(new RegExp('\[[a-z]+\]$'), '');
    content = fix_template_context(content, context);
    var new_id = new Date().getTime();
    content = fix_template_names(content, assoc, new_id);

    var field   = '';
    if (assoc == 'lookup_keys') {
      $('#smart_vars .smart-var-tabs .active, #smart_vars .stacked-content .active').removeClass('active');
      var pill = "<li class='active'><a data-toggle='pill' href='#" + new_id + "' id='pill_" + new_id + "'><div class='clip'>" + __('new') + "</div><span class='close pull-right'>&times;</span></a></li>"
      $('#smart_vars .smart-var-tabs').prepend(pill);
      field = $('#smart_vars .stacked-content').prepend($(content).addClass('active'));
      $('#smart_vars .smart-var-tabs li.active a').show('highlight', 500);
    } else {
      field = $(content).insertBefore($(item));
    }
    $(item).closest("form").trigger({type: 'nested:fieldAdded', field: field});
    $('a[rel="popover"]').popover({html: true});
    $('a[rel="twipsy"]').tooltip();
    return new_id;
}

function remove_child_node(item) {
  var hidden_field = $(item).prev('input[type=hidden]')[0];
  if(hidden_field) {
    hidden_field.value = '1';
  }

  $(item).closest('.fields').hide();
  if($(item).parent().hasClass('fields')) {
    var pill_id = '#pill_' + $(item).closest('.fields')[0].id
    var pill = $(pill_id);
    var undo_link = $("<a href='#'>" +pill.html()+"</a>").attr("data-pill", pill_id);

    pill.parent().hide();
    undo_link.on('click', function(){ undo_remove_child_node(this);});
    undo_link.find('span').remove();
    $('.lookup-keys-container:visible').find('.undo-smart-vars').append(undo_link).show();
  }
  $(item).closest("form").trigger('nested:fieldRemoved');
  return false;
}

function undo_remove_child_node(item){
  var container = $('.lookup-keys-container:visible');
  var link = container.find($(item).attr("data-pill"));
  var fields = container.find(link.attr("href"));

  var hidden_field = fields.find('input[type=hidden]').first()[0];
  if(hidden_field) {
    hidden_field.value = '0';
  }

  container.find('.smart-var-tabs li.active').removeClass('active');
  container.find('.fields.active').hide().removeClass('active');
  fields.show().addClass('active');
  link.parent().show().addClass('active');

  $(item).remove();
  if (container.find('.undo-smart-vars a').length == 0) {
    container.find('.undo-smart-vars').hide();
  }
  return false;
}

function toggleOverrideValue(item) {
  var override = $(item).is(':checked');
  var fields = $(item).closest('.fields');
  var mandatory = fields.find("[id$='_required']");
  var type_field = fields.find("[id$='_key_type']");
  var validator_type_field = fields.find("[id$='_validator_type']");
  var default_value_field = fields.find("[id$='_default_value']");
  var use_puppet_default = fields.find("[id$='use_puppet_default']");
  var override_value_div = fields.find("[id$='lookup_key_override_value']");
  var pill_icon = $('#pill_' + fields[0].id +' i');

  mandatory.attr('disabled', override ? null : 'disabled');
  type_field.attr('disabled', override ? null : 'disabled');
  validator_type_field.attr('disabled', override ? null : 'disabled');
  default_value_field.attr('disabled', override && !$(use_puppet_default).is(':checked') ? null : 'disabled' );
  use_puppet_default.attr('disabled', override ? null : 'disabled' );
  pill_icon.attr("class", override ? 'glyphicon glyphicon-flag' : "glyphicon- ");
  override_value_div.toggle(override);
}

function changeCheckboxEnabledStatus(checkbox, shouldEnable) {
  if (shouldEnable) {
    $(checkbox).attr('disabled', null);
  }
  else {
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
  changeCheckboxEnabledStatus(mergeOverrides, keyType == 'array' || keyType == 'hash');
  changeCheckboxEnabledStatus(avoidDuplicates, keyType == 'array' && $(mergeOverrides).attr('checked') == 'checked');
}

function mergeOverridesChanged(item) {
  var fields = $(item).closest('.fields');
  var keyType = fields.find("[id$='_key_type']").val();
  var avoidDuplicates = fields.find("[id$='_avoid_duplicates']");
  changeCheckboxEnabledStatus(avoidDuplicates, keyType == 'array' && item.checked);
}

function toggleUsePuppetDefaultValue(item, value_field) {
  var use_puppet_default = $(item).is(':checked');
  var fields = $(item).closest('.fields');
  var value_field = fields.find('[id$=' + value_field + ']');

  value_field.attr('disabled', use_puppet_default ? 'disabled' : null );
}

function filterByEnvironment(item){
  if ($(item).val()=="") {
    $('ul.smart-var-tabs li[data-used-environments] a').removeClass('text-muted');
    return;
  }
  var selected = $(item).find('option:selected').text();
  $('ul.smart-var-tabs li[data-used-environments] a').addClass('text-muted');
  $('ul.smart-var-tabs li[data-used-environments*="'+selected+'"] a').removeClass('text-muted');
}

function filterByClassParam(item) {
  var term = $(item).val().trim();
  if (term.length > 0) {
    $('ul.smart-var-tabs li[data-used-environments]').removeClass('search-marker').addClass('hide');
    $('ul.smart-var-tabs li[data-used-environments] a[href*='+term+']:not(.selected-marker)').parent().addClass('search-marker').removeClass('hide');
  } else{
    $('ul.smart-var-tabs li[data-used-environments]:not(.selected-marker)').addClass('search-marker').removeClass('hide');
  }
  return false;
}

function validatorTypeSelected(item){
  var validatorType = $(item).val();
  var validator_rule_field = $(item).closest('.fields').find("[id$='_validator_rule']");
  validator_rule_field.attr('disabled', validatorType == "" ? 'disabled' : null);
}
