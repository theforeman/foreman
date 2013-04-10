$.fn.flot_pie = function(){
  var options = arguments[0] || {};
  $(this).each(function(i,el){
    var target = $(el);

    $.plot(target, target.data('series'), {
      colors: ['#4572A7','#AA4643','#89A54E','#80699B','#3D96AE','#DB843D','#92A8CD','#A47D7C','#B5CA92'],
      series: {
        pie: options.pie || {
          show: true,
          radius: 1,
          label: {
            show: true,
            radius: 1/2,
            formatter: function(label, series){
              return '<div class="pie-labels">'+label+'<br/>'+Math.round(series.percent)+'%</div>';
            },
            threshold: 0.1
          },
          highlight: {
            opacity: 0.1
          }
        }
      },
      legend: {
        show: false
      },
      grid: {
        hoverable: true,
        clickable: true
      }
    });
    bind_hover_event(target, function(item){
      var percent = Math.round(item.series.percent);
      return item.series.label + ' ('+percent+'%)';
    });
    $(target).bind("plotclick", function (event, pos, item) {
      search_on_click(event, item);
    });
  });
}

function expanded_pie(target, data){
  $.plot(target, data, {
    colors: ['#4572A7','#AA4643','#89A54E','#80699B','#3D96AE','#DB843D','#92A8CD','#A47D7C','#B5CA92'],
    series: {
      pie: {
        show: true,
        labels: {
          show:true
        }
      }
    },
    legend: {
      show: false
    },
    grid: {
      clickable: true
    }
  });

  target.bind("plotclick", function (event, pos, item) {
    search_on_click(event, item);
  });
}

$.fn.flot_bar = function(){
  var options = arguments[0] || {};
  $(this).each(function(i,el){
    var target = $(el);

    $.plot($(target), [{ data: target.data('chart') }], {
      series: {
        bars: {
          show: true,
          barWidth: 0.6,
          fill: 0.8
        },
        color: "#4572A7"
      },
      xaxis: {
        axisLabel: target.data('xaxis-label'),
        tickLength: 0, // hide gridlines
        ticks: target.data('ticks')
      },
      yaxis: {
        axisLabel: target.data('yaxis-label'),
        axisLabelPadding: 15,
        minTickSize: 1,
        tickDecimals: 0
      },
      grid: {
        hoverable: true,
        borderWidth: 0
      },
      legend: {
        show: false
      }
    });
    bind_hover_event(target, function(item){return "<b>" + target.data('yaxis-label') + ":</b> " + item.datapoint[1];});
  });
}

function flot_time_chart(target, data, legendOptions){
  var chart_options = {
    series: {
      stack: target.hasClass('stack') ? true : null,
      lines: {
        show: true,
        fill: target.hasClass('stack') ? 0.8 : false
      }
    },
    xaxis: {
      mode: "time",
      axisLabel: target.data('xaxis-label'),
      tickLength: 0 // hide gridlines
    },
    yaxis: {
      axisLabel: target.data('yaxis-label'),
      axisLabelPadding: 12,
      minTickSize: 1,
      tickDecimals: 0
    },
    selection: {
      mode: "x"
    },
    grid: {
      hoverable: true,
      borderWidth: 0
    },
    legend: legendOptions
  }
  $.plot($(target), data , chart_options);
  bind_hover_event(target, function(item){return "<b>" + item.series.label + ":</b> " + item.series.data[item.dataIndex][1];});
  target.bind("plotselected", function (event, ranges) {flot_zoom(target, chart_options, ranges)});
}

$.fn.flot_chart = function(){
  $(this).each(function(i,el){
    flot_time_chart($(el), $(el).data('series'), chart_legend_options($(el)) );
  });
}

function chart_legend_options(item){
  if(item.data('series').length == 1) return {show: false};
  var options = item.data('legend-options');
  switch (options)
  {
    case "external":
      return {show: true,
        noColumns:4,
        container:"#legendContainer",
        labelFormatter: function(label, series) {
          return '<a rel="twipsy" data-original-title="Details" href="' + series.href + '">' + label + '</a>';
        }
      }
    case "hide":
      return {show: false};
    default:
      return {show: true};
  }
}

function flot_zoom(target, options, ranges) {
  // clamp the zooming to prevent eternal zoom
  if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
    ranges.xaxis.to = ranges.xaxis.from + 0.00001;
  if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
    ranges.yaxis.to = ranges.yaxis.from + 0.00001;

  // do the zooming
  plot = $.plot(target, target.data('series'),
      $.extend(true, {}, options, {
        xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
        yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
      }));
  if(target.parents('.stats-well').find('.reset-zoom').size() == 0){
    target.parents('.stats-well').prepend("<a class='reset-zoom btn btn-small'>Reset zoom</a>");
  }
}

function reset_zoom(item){
  target = $(item).parents('.stats-well').find('.statistics-chart');
  target.flot_chart();
  $(item).remove();
}

function showTooltip(pos, item, formater) {
  var content = formater(item);
  $('<div id="flot-tooltip">' + content + '</div>').css({
    top: pos.pageY - 40,
    left: pos.pageX -10,
    'border-color': item.series.color
  }).appendTo("body").show();
}

$previousPoint=null;
function bind_hover_event(target, formater){
  $(target).bind("plothover", function (event, pos, item) {
    if (item) {
      if ($previousPoint != item.datapoint) {
        $previousPoint = item.datapoint;
        $("#flot-tooltip").remove();
        showTooltip(pos, item, formater);
      }
    } else {
      $("#flot-tooltip").remove();
      $previousPoint = null;
    }
  });
}

function search_on_click(event, item) {
  var link = $(event.currentTarget).data('url');
  if (link == undefined) return;
  if (link.indexOf("~VAL2~") != -1) {
    var strSplit = item.series.label.split(" ");
    var val1 = strSplit[0];
    var val2 = strSplit[1];
    link = link.replace("~VAL2~", val2);
  } else {
    var val1 = item.series.label;
    if (val1.indexOf(" ") != -1) val1 = '"' + val1 +'"';
  }
  link = link.replace("~VAL1~", val1);
  event.preventDefault();
  window.location.href = link;
}

function get_pie_chart(div, url) {
  if($("#"+div).length == 0)
  {
    $('body').append('<div id="' + div + '" class="modal fade"></div>');
    $("#"+div).append('<div class="modal-header"><a href="#" class="close" data-dismiss="modal">&times;</a><h3>Fact Chart</h3></div>')
        .append('<div id="' + div + '-body" class="fact_chart modal-body">Loading ...</div>');
    $("#"+div).modal('show');
    $.getJSON(url, function(data) {
      var target = $("#"+div+"-body");
      expanded_pie(target, data.values)
      target.attr('data-url', foreman_url("/hosts?search=facts." + data.name + "~~VAL1~"));
    });
  } else {$("#"+div).modal('show');}
}

function expand_chart(ref){
  var chart = $(ref);
  if (!chart.hasClass('statistics-pie')){
    chart = $(ref).parent().find('.statistics-pie');
  }
  var modal_id = chart.attr('id')+'_modal';
  if($("#"+modal_id).length == 0)
  {
    var new_chart = chart.clone().empty().attr('id', modal_id + "_chart").removeClass('small');
    $('body').append('<div id="' + modal_id + '" class="modal fade"></div>');
    $("#"+modal_id).append('<div class="modal-header"><a href="#" class="close" data-dismiss="modal">&times;</a><h3> ' +chart.data('title')+ ' </h3></div>')
        .append(new_chart);
    expanded_pie(new_chart, new_chart.data('series'));
  }
  $("#"+modal_id).modal('show');
}

function legend_selected(item){
  $(item).closest('td').toggleClass('disabled');
  $(item).closest('td').next().toggleClass('disabled');
  var target = $(item).parents('.statistics-chart');
  var series = target.clone().data('series');
  var legend = target.find('.legend').clone();
  var data= [];
  // Remove the data series.
  target.find('.legend td.legendLabel:not(.disabled)').each(function() {
    var key = $(this).text();
    for (var i = 0; i < series.length; i++) {
      if (series[i].label === key) {
        data.push(series[i]);
        return true;
      }
    }
  });
  flot_time_chart(target, data);
  target.find('.legend').remove();
  target.append(legend);

}

function ext_legend_selected(item){
  $(item).closest('td').toggleClass('disabled');
  $(item).closest('td').next().toggleClass('disabled');
  var target = $('.statistics-chart');
  var series = target.clone().data('series');
  var data= [];
  // Remove the data series.
  $('#legendContainer table td.legendLabel:not(.disabled)').each(function() {
    var key = $(this).text();
    for (var i = 0; i < series.length; i++) {
      if (series[i].label === key) {
        data.push(series[i]);
        return true;
      }
    }
  });

  flot_time_chart(target, data, {show: false});
}

$(function() {
  $(".statistics-pie").flot_pie();
  $(".statistics-bar").flot_bar();
  $(".statistics-chart").flot_chart();
  $(document).on('click', '.reset-zoom', function () {reset_zoom(this)});
  $(document).on('click', '.legend .legendColorBox, .legend .legendLabel', function() { legend_selected(this)});
  $(document).on('click', '#legendContainer .legendColorBox, .legendContainer .legendLabel', function() { ext_legend_selected(this)});
});

$(window).resize(function() {
  $(".statistics-bar").flot_bar();
  $(".statistics-chart").flot_chart();
});