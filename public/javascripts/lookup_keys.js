//on load
$(function() {
  //select the first tab
  $('.nav-pills li a span').hide();
  select_first_tab();
  //make the remove variable button visible only on the active pill
  $('.nav-pills li a').on('click',function(){ show_delete_button(this);});
  //remove variable click event
  $('.nav-pills li a span').on('click',function(){ remove_node(this);});
})

function select_first_tab(){
  if ($('.nav-pills li').size() > 1){
    $('.tab-content .fields').first().addClass('active');
    $('.nav-pills li').first().addClass('active');
  }
  $('.nav-pills li.active a span').show('highlight',5  );
}

function show_delete_button(item){
  $('.nav-pills li a span:visible').hide();
  $(item).children("span").show('highlight',5);
  if($(item).hasClass('label-success') && ($('.nav-pills li').size()>1)){
    select_first_tab();
  }
}

function remove_node(item){
  $($(item).parent("a").attr("href")).children('.btn-danger').click();
  var pills = $('.nav-pills li a');
  if (pills.size() > 1){pills.first().click();}
  $('.nav-pills li.active a').click();
}

function add_child_node(item) {
    // Setup
    var assoc   = $(item).attr('data-association');           // Name of child
    var content = $('#' + assoc + '_fields_template').html(); // Fields template

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
      $('.nav-pills .active, .pill-content .active').removeClass('active');
      var pill = "<li class='active'><a onclick='show_delete_button(this);' data-toggle='pill' href='#new_" + new_id + "' id='pill_new_" + new_id + "'>new<span onclick='remove_node(this);' class='label label-important fr'>&times;</span></a></li>"
      $('.nav-pills').prepend(pill);
      field = $('.pill-content').prepend($(content).addClass('active'));
      $('.nav-pills li.active a').show('highlight', 500);
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

