$(document).on('click', ".table-two-pane td", function(e) {
  var item = $(this).find("a[href$='edit']");
  if(item.length){
    e.preventDefault();
    two_pane_open(item);
  }
});

$(document).on('click', "#title_action a[href$='new']", function(e) {
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
  $('td.active').removeClass('active');
  $(item).parent('td').addClass('active');

  var href = $(item).attr('href');
  $.ajax({
    type:'GET',
    url: href,
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
  $.ajax({
    type:'POST',
    url: url,
    data: $('form').serialize(),
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
    $('.table-two-pane').wrap( "<div class='row'><div class='span3 two-pane-left'></div></div>");
  }
  var placeholder = spinner_placeholder(_('Loading'));
  $('.two-pane-left').after("<div class='span9 two-pane-right'><div class='well'>" + placeholder + "</div></div>");

}

// place the content into the right pane
function right_pane_content(response){
  if (handle_redirect(response)) return; //session expired redirect to login

  var form_content = $("#content form.well", response);
  if (form_content.length){
    $('.two-pane-right').html(form_content);
    $('.two-pane-right form').removeClass('form-horizontal');
    $('.two-pane-right form').prepend("<div class='fr close-button'><a class='two-pane-close' href='#'>&times;</a></div>");
    $('.form-actions div').addClass('pull-right');
    $('.form-actions a').addClass('two-pane-close');
    fix_multi_checkbox();
  } else {
    // response is not a form use the entire page
    $('#content').replaceWith($("#content", response));
  }
  $(document.body).trigger('ContentLoad');
}

function fix_multi_checkbox(){
  $('.two-pane-right .icon-check').parents('.control-group').each(function(){
    var label = $(this).find('.control-label').hide().text();
    $(this).find('a').append(label).addClass('select-all');
  })
}

// clear form errors classes.
function clear_errors(){
  $('.error .help-inline').hide();
  $('.error').removeClass('error');
  $('.tab-error').removeClass('tab-error');
  $('.alert-error').remove();
}

// when ajax call hit a session time out it should handle the redirect to login correctly.
function handle_redirect(response){
  var redirect = response.redirect || $("form[action$='/users/login']", response).attr('action');
  if(redirect){
    window.location.replace(redirect);
  }
  return redirect
}

