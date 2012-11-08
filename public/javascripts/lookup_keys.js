//on load
$(function() {
  //select the first tab
  $('.smart-var-tabs li a span').hide();
  select_first_tab();
  //make the remove variable button visible only on the active pill
  $('.smart-var-tabs li a').on('click',function(){ show_delete_button(this);});
  //remove variable click event
  $('.smart-var-tabs li a span').on('click',function(){ remove_node(this);});
})

function select_first_tab(){
  if ($('.smart-var-tabs li').size() > 1){
    $('.tab-content .fields').first().addClass('active');
    $('.smart-var-tabs li').first().addClass('active');
  }
  $('.smart-var-tabs li.active a span').show('highlight',5  );
}

function show_delete_button(item){
  $('.smart-var-tabs li a span:visible').hide();
  $(item).children("span").show('highlight',5);
  if($(item).hasClass('label-success') && ($('.smart-var-tabs li').size()>1)){
    select_first_tab();
  }
}

function remove_node(item){
  $($(item).parent("a").attr("href")).children('.btn-danger').click();
  var pills = $('.smart-var-tabs li a');
  if (pills.size() > 1){pills.first().click();}
  $('.smart-var-tabs li.active a').click();
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

    // Make a unique ID for the new child
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();
    content     = content.replace(regexp, "new_" + new_id);
    var field   = '';
    if (assoc == 'lookup_keys') {
      $('#smart_vars .smart-var-tabs .active, #smart_vars .smart-var-content .active').removeClass('active');
      var pill = "<li class='active'><a onclick='show_delete_button(this);' data-toggle='pill' href='#new_" + new_id + "' id='pill_new_" + new_id + "'>new<span onclick='remove_node(this);' class='label label-important fr'>&times;</span></a></li>"
      $('#smart_vars .smart-var-tabs').prepend(pill);
      field = $('#smart_vars .smart-var-content').prepend($(content).addClass('active'));
      $('#smart_vars .smart-var-tabs li.active a').show('highlight', 500);
    } else {
      field = $(content).insertBefore($(item));
    }
    $(item).closest("form").trigger({type: 'nested:fieldAdded', field: field});
    $('a[rel="popover"]').popover();
    return new_id;
}

function remove_child_node(item) {
  var hidden_field = $(item).prev('input[type=hidden]')[0];
  if(hidden_field) {
    hidden_field.value = '1';
  }

  $(item).closest('.fields').hide();
  if($(item).parent().hasClass('fields')) {
    $('#pill_' + $(item).closest('.fields').attr('id')).empty().remove();
  }
  $(item).closest("form").trigger('nested:fieldRemoved');

  return false;
}

function toggleOverrideValue(item) {
  var override = $(item).is(':checked');
  var mandatory = $(item).closest('.fields').find("[id$='_required']");
  var type_field = $(item).closest('.fields').find("[id$='_key_type']");
  var validator_type_field = $(item).closest('.fields').find("[id$='_validator_type']");
  var default_value_field = $(item).closest('.fields').find("[id$='_default_value']");
  var override_value_div = $(item).closest('.fields').find("[id$='lookup_key_override_value']");

  mandatory.attr('disabled', override ? null : 'disabled');
  type_field.attr('disabled', override ? null : 'disabled');
  validator_type_field.attr('disabled', override ? null : 'disabled');
  default_value_field.attr('disabled', override ? null : 'disabled' );
  override_value_div.toggle(override);
}

function filterByEnvironment(item){
  if ($(item).val()=="") {
    $('ul.smart-var-tabs li[data-used-environments] a').removeClass('grey');
    return;
  }
  var selected = $(item).find('option:selected').text();
  $('ul.smart-var-tabs li[data-used-environments] a').addClass('grey');
  $('ul.smart-var-tabs li[data-used-environments*="'+selected+'"] a').removeClass('grey');
}

function validatorTypeSelected(item){
  var validatorType = $(item).val();
  var validator_rule_field = $(item).closest('.fields').find("[id$='_validator_rule']");
  validator_rule_field.attr('disabled', validatorType == "" ? 'disabled' : null);
}
