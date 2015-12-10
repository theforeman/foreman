var disabled_tabs = [];

var original_tab_fn = $.fn.tab;
$.fn.tab = function ( option ) {
  if(disabled_tabs.indexOf($(this).get(0)) < 0) {
      original_tab_fn.call(this, option);
  }
}

$(document).on('click', ".table-two-pane .display-two-pane a", function(e) {
  if ($('.table-two-pane').length) {
    e.preventDefault();
    two_pane_open(this);
  }
});

$(document).on('click', "#title_action a[href$='new']", function(e) {
  if ($('.table-two-pane').length && $(this).data('target') != 'full-page') {
    e.preventDefault();
    two_pane_open(this);
  }
});

$(document).on('click', "a[href$='new'].new_two_pane", function(e) {
  if ($('.table-two-pane').length) {
    e.preventDefault();
    two_pane_open(this);
  }
});

$(document).on('click', "a[href$='edit'].edit_two_pane", function(e) {
  if ($('.table-two-pane').length) {
    e.preventDefault();
    two_pane_open(this);
  }
});

$(document).on('submit','.two-pane-right', function() {
  two_pane_submit();
  return false;
});

$(document).on('click', ".two-pane-close", function(e) {
    e.preventDefault();
    two_pane_close();
});

// open the new/edit from in the right pane
function two_pane_open(item){
  hide_columns();

  disabled_tabs = $('ul.nav-tabs li a').toArray();
  $('ul.nav-tabs li').not(".active").addClass('disabled');
  $('td.active').removeClass('active');
  $(item).parent('td').addClass('active');

  var href = $(item).attr('href');
  $.ajax({
    type:'GET',
    url: href,
    headers: {"X-Foreman-Layout": "two-pane"},
    success: function(response){
      right_pane_content(response);
    },
    error: function(response){
      $('#content').html(response.responseText);
    }
  });
}

// submit the form in the right pane, using ajax.
function two_pane_submit(){
  clear_errors();
  $('input[type="submit"]').attr('disabled', true);
  $("body").css("cursor", "progress");

  var url = $('.two-pane-right form').attr('action');
  var data;
  if (!("FormData" in window)) {
    data = $('.two-pane-right form').serialize();
    content_type = 'application/x-www-form-urlencoded; charset=UTF-8';
    process_data = true;
  } else {
    data = new FormData($('.two-pane-right form')[0]);
    content_type = false;
    process_data = false;
  }

  $.ajax({
    type:'POST',
    url: url,
    headers: {"X-Foreman-Layout": "two-pane"},
    data: data,
    processData: process_data,
    contentType: content_type,
    success: function(response){
      right_pane_content(response);
    },
    error: function(response){
      $('#content').html(response.responseText);
    },
    complete: function(){
      $("body").css("cursor", "auto");
      $('input[type="submit"]').attr('disabled', false);
    }
  });
}

// show all the table columns and remove the two-pane structure
function two_pane_close(){
  $('ul.nav-tabs li').removeClass('disabled');
  $disabled_tabs = [];
  $('td.active').removeClass('active');
  $('.two-pane-right').remove();
  $('.table-two-pane tr td').show();
  $('.table-two-pane th').show();
  $("#title_action").show();
  $('.pagination').show();
  if ($('.two-pane-left').length){
    $('.table-two-pane').unwrap().unwrap();
  }
}

// hide all table columns except for the first one.
function hide_columns(){
  $('.table-two-pane tr td').hide();
  $('.table-two-pane tr td:nth-child(1)').show();
  $('.table-two-pane th').hide();
  $('.table-two-pane th:nth-child(1)').show();
  $("#title_action").hide();
  $('.two-pane-right').remove();
  $('.pagination').hide();
  if ($('.two-pane-left').length == 0){
    $('.table-two-pane').wrap( "<div class='row'><div class='col-md-3 two-pane-left'></div></div>");
  }
  var placeholder = spinner_placeholder(__('Loading'));
  $('.two-pane-left').after("<div class='col-md-9 two-pane-right'><div class='well'>" + placeholder + "</div></div>");

}

// place the content into the right pane
function right_pane_content(response){
  if (handle_redirect(response)) return; //session expired redirect to login

  if (!$("#content", response).length){
    $('.two-pane-right').html(response);
    $('.two-pane-right form').prepend("<div class='fr close-button'><a class='two-pane-close' href='#'>&times;</a></div>");
    $('.form-actions a').addClass('two-pane-close');
    fix_multi_checkbox();
  } else {
    // response is not a form use the entire page
    $('#content').replaceWith($("#content", response));
  }
  $(document.body).trigger('ContentLoad');
}

function fix_multi_checkbox(){
  $('.two-pane-right .glyphicon-icon-check').parents('.form-group').each(function(){
    var label = $(this).find('.control-label').hide().text();
    $(this).find('a').append(label).addClass('select-all');
  })
}

// clear form errors classes.
function clear_errors(){
  $('.error .help-block').hide();
  $('.error').removeClass('error');
  $('.tab-error').removeClass('tab-error');
  $('.alert-danger').remove();
}

// when ajax call hit a session time out it should handle the redirect to login correctly.
function handle_redirect(response){
  var redirect = response.redirect || $("form[action$='/users/login']", response).attr('action');
  if(redirect){
    window.location.replace(redirect);
  }
  return redirect
}

