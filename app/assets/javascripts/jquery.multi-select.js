$(function(){
  multiSelectOnLoad();
})

function multiSelectOnLoad(){
  $('select[multiple]:not(.without_multiselect)').each(function(i,item){
    $(item).multiSelect({
      selectableHeader: $("<div class='ms-header'>" + __('All items') + " <input placeholder='" + __('Filter') + "' class='ms-filter' type='text'><a href='#' title='" + __('Select All') + "' class='ms-select-all pull-right glyphicon glyphicon-plus'></a></div>"),
      selectionHeader: $("<div class='ms-header'>" + __('Selected items') + "<a href='#' title='" + __('Deselect All') + "' class='ms-deselect-all pull-right glyphicon glyphicon-minus'></a></div>"),
      afterDeselect: function(value){
        var current_select = $(item).closest('.tab-pane').find('select[multiple]');
        current_select.data('descendants', null);
        $(current_select).multiSelect('refresh');
        multiSelectToolTips();
      }
    })
  });
  multiSelectToolTips();
}

function multiSelectToolTips(){
  $('select[multiple]').each(function(i,item){
    var mismatches = $(item).attr('data-mismatches');
    var inheriteds = $(item).attr('data-inheriteds');
    var descendants = $(item).attr('data-descendants');
    var useds = $(item).attr('data-useds');
    var msid = '#ms-'+item.id;
    // it an <li> items match multiple tooltips, then only the first tooltip will show
    if (!(mismatches == null || mismatches == 'undefined')) {
      var missing_ids = $.parseJSON(mismatches);
      $.each(missing_ids, function(index,missing_id){
        opt_id = sanitize(missing_id+'');
        $(msid).find('li#'+opt_id+'-selectable').addClass('delete').tooltip({container: 'body', title: __("Select this since it belongs to a host"), placement: "left"});
      })
    }
    if (!(useds == null || descendants == 'useds')) {
      var used_ids = $.parseJSON(useds);
      $.each(used_ids, function(index,used_id){
        opt_id = sanitize(used_id+'');
        $(msid).find('li#'+opt_id+'-selection').addClass('used_by_hosts').tooltip({container: 'body', title: __("This is used by a host"), placement: "right"});
      })
    }
    if (!(inheriteds == null || inheriteds == 'undefined')) {
      var inherited_ids = $.parseJSON(inheriteds);
      $.each(inherited_ids, function(index,inherited_id){
        opt_id = sanitize(inherited_id+'');
        $(msid).find('li#'+opt_id+'-selection').addClass('inherited').tooltip({container: 'body', title: __("This is inherited from parent"), placement: "right"});
      })
    }
    if (!(descendants == null || descendants == 'undefined')) {
      var descendant_ids = $.parseJSON(descendants);
      $.each(descendant_ids, function(index,descendant_id){
        opt_id = sanitize(descendant_id+'');
        $(msid).find('li#'+opt_id+'-selection').addClass('descendants').tooltip({container: 'body', title: __("Parent is already selected"), placement: "right"});
        $(msid).find('li#'+opt_id+'-selectable').addClass('descendants').tooltip({container: 'body', title: __("Parent is already selected"), placement: "left"});
      })
    }
  })
}

// function below is copy/paste from source of multi-select-rails gem
// it takes the option value and returns a value used in css id
function sanitize(value){
    var hash = 0, i, char;
    if (value.length == 0) return hash;
    var ls = 0;
    for (i = 0, ls = value.length; i < ls; i++) {
      char  = value.charCodeAt(i);
      hash  = ((hash<<5)-hash)+char;
      hash |= 0; // Convert to 32bit integer
    }
    return hash;
}

$(document).on('click', '.ms-select-all', function () {
  // can't use multiSelect('select_all') because it adds filtered out items too.
    $(this).closest('.form-group').find('.ms-selectable .ms-list :visible').click();
    return false;
});

$(document).on('click', '.ms-deselect-all', function () {
    // can't use multiSelect('deselect_all') because it is deselecting disabled items too.
    var ms = $(this).closest('.form-group').find('select[multiple]');
    ms.find('option:not(":disabled")').prop('selected', false);
    ms.multiSelect('refresh');
    return false;
});

$(document).on('keyup', '.ms-filter', function() {
    var term = $(this).val().trim();
    var selectable =   $(this).closest('.ms-selectable').find('.ms-elem-selectable');

    if (term.length > 0) {
      selectable.addClass('hide');
      selectable.find('span:icontains('+term+')').parent('li').removeClass('hide');
    } else {
      selectable.removeClass('hide');
    }
});
