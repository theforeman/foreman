function flot_time_chart(target, data, legendOptions) {
  var chart_options = {
    series: {
      stack: target.hasClass('stack') ? true : null,
      lines: {
        show: true,
        fill: target.hasClass('stack') ? 0.8 : false,
      },
    },
    xaxis: {
      mode: 'time',
      axisLabel: target.data('xaxis-label'),
      tickLength: 0, // hide gridlines
    },
    yaxis: {
      axisLabel: target.data('yaxis-label'),
      axisLabelPadding: 12,
      minTickSize: 1,
      tickDecimals: 0,
      min: 0,
    },
    selection: {
      mode: 'x',
    },
    grid: {
      hoverable: true,
      borderWidth: 0,
    },
    legend: legendOptions,
  };
  $.plot($(target), data, chart_options);
  bind_hover_event(target, function(item) {
    return item.series.label + ': ' + item.series.data[item.dataIndex][1];
  });
  target.bind('plotselected', function(event, ranges) {
    flot_zoom(target, chart_options, ranges);
  });
}

$.fn.flot_chart = function() {
  $(this).each(function(i, el) {
    flot_time_chart($(el), $(el).data('series'), chart_legend_options($(el)));
  });
};

function chart_legend_options(item) {
  if (item.data('series').length == 1) return { show: false };
  var options = item.data('legend-options');
  switch (options) {
    case 'external':
      return {
        show: true,
        noColumns: 4,
        container: '#legendContainer',
        labelFormatter: function(label, series) {
          return (
            '<a rel="twipsy" data-original-title="' +
            __('Details') +
            '" href="' +
            series.href +
            '">' +
            _.escape(label) +
            '</a>'
          );
        },
      };
    case 'hide':
      return { show: false };
    default:
      return { show: true, margin: [0, -60] };
  }
}

function flot_zoom(target, options, ranges) {
  // clamp the zooming to prevent eternal zoom
  if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
    ranges.xaxis.to = ranges.xaxis.from + 0.00001;
  if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
    ranges.yaxis.to = ranges.yaxis.from + 0.00001;

  // do the zooming
  plot = $.plot(
    target,
    target.data('series'),
    $.extend(true, {}, options, {
      xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
      yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to },
    })
  );
  if (target.parents('.stats-well').find('.reset-zoom').length == 0) {
    target
      .parents('.stats-well')
      .prepend("<a class='reset-zoom btn btn-sm'>" + __('Reset zoom') + '</a>');
  }
}

function reset_zoom(item) {
  target = $(item)
    .parents('.stats-well')
    .find('.statistics-chart');
  target.flot_chart();
  $(item).remove();
}

function showTooltip(pos, item, formater) {
  var content = formater(item);
  $('<div id="flot-tooltip">')
    .text(content)
    .css({
      top: pos.pageY - 40,
      left: pos.pageX - 10,
      'border-color': item.series.color,
    })
    .appendTo('body')
    .zIndex(5000)
    .show();
}

$previousPoint = null;
function bind_hover_event(target, formater) {
  $(target).bind('plothover', function(event, pos, item) {
    if (item) {
      $(target).css('cursor', 'pointer');
      if ($previousPoint != item.datapoint) {
        $previousPoint = item.datapoint;
        $('#flot-tooltip').remove();
        showTooltip(pos, item, formater);
      }
    } else {
      $(target).css('cursor', 'default');
      $('#flot-tooltip').remove();
      $previousPoint = null;
    }
  });
}

function legend_selected(item) {
  $(item)
    .closest('td')
    .toggleClass('disabled');
  $(item)
    .closest('td')
    .next()
    .toggleClass('disabled');
  var target = $(item).parents('.statistics-chart');
  var series = target.clone().data('series');
  var legend = target.find('.legend').clone();
  var data = [];
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

function ext_legend_selected(item) {
  $(item)
    .closest('td')
    .toggleClass('disabled');
  $(item)
    .closest('td')
    .next()
    .toggleClass('disabled');
  var target = $('.statistics-chart');
  var series = target.clone().data('series');
  var data = [];
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

  flot_time_chart(target, data, { show: false });
}

function updateChart(item, status) {
  if (status == 'success')
    $(item)
      .find('.statistics-chart')
      .flot_chart();
  else $(item).text(__('Failed to load chart'));
}

$(function() {
  $('[data-toggle="tooltip"]').tooltip();
  refreshCharts();
  $(document).on('click', '.reset-zoom', function() {
    reset_zoom(this);
  });
  $(document).on(
    'click',
    '.legend .legendColorBox, .legend .legendLabel',
    function() {
      legend_selected(this);
    }
  );
  $(document).on(
    'click',
    '#legendContainer .legendColorBox, .legendContainer .legendLabel',
    function() {
      ext_legend_selected(this);
    }
  );
});

$(window).on('resize', refreshCharts);

function refreshCharts() {
  $('.statistics-chart:visible').flot_chart();
}
