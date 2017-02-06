$(document).on('ContentLoad', function(){start_gridster(); auto_refresh()});

$(document).on("click",".widget_control .minimize" ,function(){ hide_widget(this);});
$(document).on("click",".widget_control .remove" ,function(){ remove_widget(this);});

var refresh_timeout;
function auto_refresh(){
  var element = $(".auto-refresh");
  clearTimeout(refresh_timeout);

  if (element[0]) {
    refresh_timeout = setTimeout(function(){
      if ($(".auto-refresh").hasClass("on")) {
        history.go(0);
      }
    },60000);
  }
}

function start_gridster(){
    var gridster = $(".gridster>ul").gridster({
        widget_margins: [10, 10],
        widget_base_dimensions: [94, 340],
        max_size_x: 12,
        min_cols: 12,
        max_cols: 12,
        autogenerate_stylesheet: false
    }).data('gridster');

    $(".gridster>ul>li[data-hide='true']").each(function(i, widget) {
        $(widget).hide();
        gridster.remove_widget(widget);
        $(".gridster>ul").append($(widget));
    });
    fill_restore_list();
}

function hide_widget(item){
    var gridster = $(".gridster>ul").gridster().data('gridster');
    var widget = $(item).parents('li.gs-w');

    widget.attr('data-hide', 'true').hide();
    gridster.remove_widget(widget);
    $(".gridster>ul").append(widget);
    fill_restore_list();
}

function remove_widget(item){
    var widget = $(item).parents('li.gs-w');
    var gridster = $(".gridster>ul").gridster().data('gridster');
    if (confirm(__("Are you sure you want to delete this widget from your dashboard?"))){
        $.ajax({
            type: 'DELETE',
            url: $(item).data('url'),
            success: function(){
                $.jnotify(__("Widget removed from dashboard."), 'success', false);
                gridster.remove_widget(widget);
                window.location.reload();
            },
            error: function(){
                $.jnotify(__("Error removing widget from dashboard."), 'error', true);
            },
        });
    }
}

function add_widget(name){
    $.ajax({
        type: 'POST',
        url: 'widgets',
        data: {'name': name},
        success: function(){
            $.jnotify(__("Widget added to dashboard."), 'success', false);
            window.location.reload();
        },
        error: function(){
            $.jnotify(__("Error adding widget to dashboard."), 'error', true);
        },
        dataType: 'json'
    });
}

function save_position(path){
    var positions = serialize_grid();
    $.ajax({
        type: 'POST',
        url: path,
        data: {'widgets': positions},
        success: function(){
            $.jnotify(__("Widget positions successfully saved."), 'success', false);
        },
        error: function(){
            $.jnotify(__("Failed to save widget positions."), 'error', true);
        },
        dataType: 'json'
    });
}

function serialize_grid(){
    var result = {};
    $(".gridster>ul>li").each(function(i, widget) {
        $widget = $(widget);
        result[$widget.data('id')] = {
            hide:   $widget.data('hide'),
            col:    $widget.data('col'),
            row:    $widget.data('row'),
            sizex:  $widget.data('sizex'),
            sizey:  $widget.data('sizey')
        };
    });

    return result;
}

function fill_restore_list(){
   $("ul>li.widget-restore").remove();
   var restore_list = [];
   var hidden_widgets = $(".gridster>ul>li[data-hide='true']");
   if (hidden_widgets.exists()){
       hidden_widgets.each(function(i, widget) {
           restore_list.push("<li class='widget-restore'><a href='#' onclick='show_widget(\"" +
               $(widget).attr('data-id') + "\")'>" +
               $(widget).attr('data-name') + "</a></li>");
       });
   } else {
       restore_list.push("<li class='widget-restore'><a>" + __('Nothing to restore') + "</a></li>");
   }
   $('#restore_list').after(restore_list.join(" "));
}

function show_widget(id){
    var gridster = $(".gridster>ul").gridster().data('gridster');
    var widget = $(".gridster>ul>li[data-id="+id+"]");
    widget.attr("data-hide", 'false');
    widget.attr("data-row", 1);
    widget.attr("data-col", 1);
    widget.show();

    gridster.register_widget(widget);
    fill_restore_list();
}

function widgetLoaded(widget){
    refreshCharts();
    tfm.tools.activateTooltips(widget);
}
