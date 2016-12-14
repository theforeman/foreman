$(function(){
  multiSelectOnLoad();
})

function multiSelectOnLoad(){
  $('select[multiple]:not(.without_jquery_multiselect)').each(function(i,item){
    $(item).multiSelect({
      selectableHeader: $("<div class='ms-header'>" + __('All items') + " <input placeholder='" + __('Filter') + "' class='form-control ms-filter' type='text'><a href='#' title='" + __('Select All') + "' class='ms-select-all pull-right glyphicon glyphicon-plus'></a></div>"),
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
    var mismatches = $(item).attr('data-mismatches'),
    inheriteds = $(item).attr('data-inheriteds'),
    descendants = $(item).attr('data-descendants'),
    useds = $(item).attr('data-useds'),
    used_all = $(item).attr('data-used-all'),
    msid = '#ms-'+item.id;
    // it an <li> items match multiple tooltips, then only the first tooltip will show
    if (!(used_all == null || used_all == 'undefined')) {
      addTooltipForElements(msid, used_all,
                            [{class_to_find_li: 'selection', clname: 'selected_taxonomy', label: "Select all option enabled for this taxonomy", position: 'right'}]);
    }
    if (!(mismatches == null || mismatches == 'undefined')) {
      addTooltipForElements(msid, mismatches,
                            [{class_to_find_li: 'selectable', clname: 'delete', label: "Select this since it belongs to a host", position: 'left'}]);
    }
    if (!(useds == null || descendants == 'useds')) {
      addTooltipForElements(msid, useds,
                            [{class_to_find_li: 'selection', clname: 'used_by_hosts', label: "This is used by a host", position: 'right'}]);
    }
    if (!(inheriteds == null || inheriteds == 'undefined')) {
      addTooltipForElements(msid, inheriteds,
                            [{class_to_find_li: 'selection', clname: 'inherited', label: "This is inherited from parent", position: 'right'}]);
    }
    if (!(descendants == null || descendants == 'undefined')) {
      addTooltipForElements(msid, descendants,
                            [{class_to_find_li: 'selection', clname: 'descendants', label: 'Parent is already selected', position: 'right'},
			     {class_to_find_li: 'selectable', clname: 'descendants', label: 'Parent is already selected', position: 'left'}]);
    }
  })
}

function addTooltipForElements(msid, json_ids, tooltips_with_options) {
  var ids = $.parseJSON(json_ids);
  $.each(ids, function(index, id){
    opt_id = sanitize(id+'');
    $.each(tooltips_with_options, function(tooltip_index, tooltip_opts) {
      $(msid).find('li#'+opt_id+'-' + tooltip_opts.class_to_find_li).addClass(tooltip_opts.clname).tooltip(
      {container: 'body', title: __(tooltip_opts.label), placement: tooltip_opts.position});
    });
  });
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
