$(document).on('ContentLoad', function(){start_gridster(); auto_refresh()});

$(document).on("click",".widget_control .remove" ,function(){ remove_widget(this);});

var refresh_timeout;
function auto_refresh(){
  var element = $(".auto-refresh");
  clearTimeout(refresh_timeout);

  if (element[0]) {
    refresh_timeout = setTimeout(function(){
      if ($(".auto-refresh").hasClass("on")) {
        Turbolinks.visit(window.location.href);
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
}

function remove_widget(item){
    var widget = $(item).parents('li.gs-w');
    var gridster = $(".gridster>ul").gridster().data('gridster');
    if (confirm(__("Are you sure you want to delete this widget from your dashboard?"))){
        $.ajax({
            type: 'DELETE',
            url: $(item).data('url'),
            success: function(){
                tfm.toastNotifications.notify({
                    message: __("Widget removed from dashboard."),
                    type: 'success'
                });
                gridster.remove_widget(widget);
                window.location.reload();
            },
            error: function(){
                tfm.toastNotifications.notify({
                    message: __("Error removing widget from dashboard."),
                    type: 'error'
                });
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
            tfm.toastNotifications.notify({
                message: __("Widget added to dashboard."),
                type: 'success'
            });
            window.location.reload();
        },
        error: function(){
            tfm.toastNotifications.notify({
                message: __("Error adding widget to dashboard."),
                type: 'error'
            });
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
            tfm.toastNotifications.notify({
                message: __("Widget positions successfully saved."),
                type: 'success'
            });
        },
        error: function(){
              tfm.toastNotifications.notify({
                message: __("Failed to save widget positions."),
                type: 'error'
              });
        },
        dataType: 'json'
    });
}

function serialize_grid(){
    var result = {};
    $(".gridster>ul>li").each(function(i, widget) {
        $widget = $(widget);
        result[$widget.data('id')] = {
            col:    $widget.data('col'),
            row:    $widget.data('row'),
            sizex:  $widget.data('sizex'),
            sizey:  $widget.data('sizey')
        };
    });

    return result;
}

function widgetLoaded(widget){
    refreshCharts();
    tfm.tools.activateTooltips(widget);
}
