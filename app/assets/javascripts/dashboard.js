
$(document).on('ContentLoad', function(){start_gridster()});

$(document).on("click",".gridster>ul>li>.close" ,function(){ hide_widget(this);});

function start_gridster(){
    if (!$(".gridster>ul>li>.close").exists()) {
        $(".gridster>ul>li").prepend("<a class='close'>&times;</a>");
    }

    read_position();
    var gridster = $(".gridster>ul").gridster({
        widget_margins: [10, 10],
        widget_base_dimensions: [82, 340],
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
    var widget = $(item).parents('li.gs_w');

    widget.attr('data-hide', 'true').hide();
    gridster.remove_widget(widget);
    $(".gridster>ul").append(widget);
    fill_restore_list();

}

function save_position(){
    var positions = JSON.stringify(serialize_grid());
    localStorage.setItem("grid-data", positions);
    window.location.reload();
}

function serialize_grid(){
    var result = [];
    $(".gridster>ul>li").each(function(i, widget) {
        result.push({
            name:   $(widget).attr('data-name'),
            id:     $(widget).attr('data-id'),
            hide:   $(widget).attr('data-hide'),
            col:    $(widget).attr('data-col'),
            row:    $(widget).attr('data-row'),
            size_x: $(widget).attr('data-sizex'),
            size_y: $(widget).attr('data-sizey')
        });
    });

    return result;
}


function read_position(){
    if (localStorage.getItem("grid-data") !== null) {
        var positions = JSON.parse(localStorage.getItem("grid-data"));

        for (var i = 0; i < positions.length; i++) {
            var position = positions[i];
            var widget = $(".gridster>ul>li[data-id="+position.id+"]");
            widget.attr("data-hide", position.hide);
            if(position.hide == 'true') {
                widget.attr("data-row", '');
                widget.attr("data-col", '');
            } else {
                widget.attr("data-row", position.row);
                widget.attr("data-col", position.col);
            }
        }
    }
}

function reset_position(){
    localStorage.removeItem("grid-data");
    window.location.reload();
}

function fill_restore_list(){
   $("ul>li.widget-restore").remove();
   var restore_list = [];
   var hidden_widgets = $(".gridster>ul>li[data-hide='true']");
   if (hidden_widgets.exists()){
       hidden_widgets.each(function(i, widget) {
           restore_list.push( "<li class='widget-restore'><a href='#' onclick='show_widget(\""+$(widget).attr('data-id')+"\")'>" + $(widget).attr('data-name') + "</a></li>" );
       });
   } else {
       restore_list.push("<li class='widget-restore'><a>" + __('Nothing to restore') + "</a></li>");
   }
   $('#restore_list').parent('ul').append(restore_list.join(" "));
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