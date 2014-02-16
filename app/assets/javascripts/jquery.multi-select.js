$(function(){
  $(":checkbox").each(function(i,item){
    ignore_checked(item);
  })
})

function ignore_checked(item){
  var active_tab = $(item).closest('.tab-pane');
  var list_items = active_tab.find('.ms-container li');

  if ($(item).is(':checked')) {
       list_items.addClass('disabled');
    } else {
       list_items.removeClass('disabled');
       active_tab.find('.ms-container li.disabled_item').addClass('disabled');
    }

}

$(function(){
  multiSelectOnLoad()
})

function multiSelectOnLoad(){
  $('select[multiple]').each(function(i,item){
    $(item).multiSelect({
      disabledClass : 'disabled disabled_item',
      selectableHeader: $("<div class='ms-header'>" + __('All items') + " <input placeholder='" + __('Filter') + "' class='ms-filter' type='text'><a href='#' title='" + __('Select All') + "' class='ms-select-all pull-right glyphicon glyphicon-plus icon-white'></a></div>"),
      selectionHeader: $("<div class='ms-header'>" + __('Selected items') + "<a href='#' title='" + __('Deselect All') + "' class='ms-deselect-all pull-right glyphicon glyphicon-minus icon-white'></a></div>")
    })
  });

  $('select[multiple]').each(function(i,item){
    var mismatches = $(item).attr('data-mismatches');
    var inheriteds = $(item).attr('data-inheriteds');
    var descendants = $(item).attr('data-descendants');
    var useds = $(item).attr('data-useds');
    if (!(mismatches == null || mismatches == 'undefined')) {
      var missing_ids = $.parseJSON(mismatches);
      $.each(missing_ids, function(index,missing_id){
        opt_id = (missing_id +"").replace(/[^A-Za-z0-9]*/gi, '_')+'-selectable';
        $('#ms-'+$(item).attr('id')).find('#'+opt_id).addClass('delete').tooltip({title: __("Select this since it belongs to a host"), placement: "left"});
      })
    }
    if (!(inheriteds == null || inheriteds == 'undefined')) {
      var inherited_ids = $.parseJSON(inheriteds);
      $.each(inherited_ids, function(index,inherited_id){
        opt_id = (inherited_id +"").replace(/[^A-Za-z0-9]*/gi, '_')+'-selection';
        $('#ms-'+$(item).attr('id')).find('#'+opt_id).addClass('inherited').tooltip({title: __("This is inherited from parent"), placement: "right"});
      })
    }
    if (!(descendants == null || descendants == 'undefined')) {
      var descendant_ids = $.parseJSON(descendants);
      $.each(descendant_ids, function(index,descendant_id){
        opt_id = (descendant_id +"").replace(/[^A-Za-z0-9]*/gi, '_')+'-selection';
        $('#ms-'+$(item).attr('id')).find('#'+opt_id).addClass('descendants').tooltip({title: __("Parent is already selected"), placement: "right"});
        opt_id = (descendant_id +"").replace(/[^A-Za-z0-9]*/gi, '_')+'-selectable';
        $('#ms-'+$(item).attr('id')).find('#'+opt_id).addClass('descendants').tooltip({title: __("Parent is already selected"), placement: "right"});
      })
    }
    if (!(useds == null || descendants == 'useds')) {
      var used_ids = $.parseJSON(useds);
      $.each(used_ids, function(index,used_id){
        opt_id = (used_id +"").replace(/[^A-Za-z0-9]*/gi, '_')+'-selection';
        $('#ms-'+$(item).attr('id')).find('#'+opt_id).addClass('used_by_hosts').tooltip({title: __("This is used by a host"), placement: "right"});
      })
    }
  })
}