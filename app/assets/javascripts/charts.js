$.fn.flot_pie = function() {
  tfm.tools.deprecate('$.flot_pie()', 'react DonutChart component', '2.5');
  var options = arguments[0] || {};
  $(this).each(function(i, el) {
    var label_exists = false;
    var target = $(el);
    var max = { data: 0 },
      sum = 0;
    $(target.data('series')).each(function(i, el) {
      sum = sum + el.data;
      if (max.data < el.data) max = el;
    });
    $.plot(target, target.data('series'), {
      colors: [
        '#0099d3',
        '#393f44',
        '#00618a',
        '#505459',
        '#057d9f',
        '#025167',
      ],
      series: {
        pie: options.pie || {
          show: true,
          innerRadius: 0.87,
          radius: 1,
          label: {
            show: true,
            radius: 0.001,
            formatter: function(label, series) {
              if (label_exists) {
                return '';
              } else {
                label_exists = true;
                return (
                  '<div class="percent">' +
                  Math.round((100 * max.data) / sum) +
                  '%</div>' +
                  _.escape(max.label)
                );
              }
            },
          },
          highlight: {
            opacity: 0.1,
          },
        },
      },
      legend: {
        show: false,
      },
      grid: {
        hoverable: true,
        clickable: true,
      },
    });
    bind_hover_event(target, function(item) {
      var percent = Math.round(item.series.percent);
      return _.escape(item.series.label) + ' (' + percent + '%)';
    });
    $(target).bind('plotclick', function(event, pos, item) {
      search_on_click(event, item);
    });
    resize_label(target.children('.pieLabel').first());
  });
};

function resize_label(label) {
  var labelOffset = parseInt(label.css('left'));
  var ratio = (label.parent().width() - 2 * labelOffset) / label.width();
  if (ratio < 1) {
    label.css('font-size', parseInt(label.css('font-size')) * ratio);
  }
  label.css('right', labelOffset); //make sure it is centered
}

function trunc_with_tooltip(val) {
  if (val.length > 10) {
    var trunced_val = _.escape(val.substring(0, 10) + '...');
    val =
      '<small data-toggle="tooltip" title="' +
      _.escape(val) +
      '">' +
      trunced_val +
      '</small>';
  }
  return val;
}

function expanded_pie(target, data) {
  var max = { data: 0 },
    sum = 0;
  var label_exist = false;
  $(data).each(function(i, el) {
    sum = sum + el.data;
    if (max.data < el.data) max = el;
  });
  $.plot(target, data, {
    colors: ['#0099d3', '#393f44', '#00618a', '#505459', '#057d9f', '#025167'],
    series: {
      pie: {
        show: true,
        innerRadius: 0.8 * (3.5 / 4),
        radius: 0.8,
        label: {
          show: true,
          radius: 0.001,
          formatter: function(label, series) {
            if (label_exist) return '';
            else {
              label_exist = true;
              return (
                '<div id="test"> <div class="percent">' +
                Math.round((100 * max.data) / sum) +
                '%</div>' +
                trunc_with_tooltip(max.label)
              );
            }
          },
        },
        highlight: {
          opacity: 0.1,
        },
      },
    },
    legend: {
      show: true,
      container: $('.legend'),
      labelFormatter: function(label, series) {
        return trunc_with_tooltip(label);
      },
    },
    grid: {
      hoverable: true,
      clickable: true,
    },
  });

  bind_hover_event(target, function(item) {
    var percent = Math.round(item.series.percent);
    return _.escape(item.series.label) + ' (' + percent + '%)';
  });
  target.bind('plotclick', function(event, pos, item) {
    search_on_click(event, item);
  });
}

$.fn.flot_bar = function() {
  var options = arguments[0] || {};
  $(this).each(function(i, el) {
    var target = $(el);

    $.plot($(target), [{ data: target.data('chart') }], {
      series: {
        bars: {
          show: true,
          barWidth: 0.6,
          fill: 1,
        },
        color: '#00618a',
      },
      xaxis: {
        axisLabel: target.data('xaxis-label'),
        tickLength: 0, // hide gridlines
        ticks: target.data('ticks'),
      },
      yaxis: {
        axisLabel: target.data('yaxis-label'),
        axisLabelPadding: 15,
        minTickSize: 1,
        tickDecimals: 0,
        min: 0,
      },
      grid: {
        hoverable: true,
        borderWidth: 0,
      },
      legend: {
        show: false,
      },
    });
    bind_hover_event(target, function(item) {
      return target.data('yaxis-label') + ': ' + item.datapoint[1];
    });
  });
};

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

function search_on_click(event, item) {
  var link = $(event.currentTarget).data('url');
  if (link == undefined) return;
  if (link.indexOf('search_by_legend') != -1) {
    var selector =
      '.label[style*="background-color:' + item.series.color + '"]';
    link = $(event.currentTarget)
      .parents('.stats-well')
      .find(selector)
      .next('a')
      .attr('href');
    if (link == undefined)
      // we are on the overview page - no stats-well parent
      link = $(event.currentTarget)
        .parents('.dashboard')
        .find(selector)
        .next('a')
        .attr('href');
  } else {
    if (link.indexOf('~VAL1~') != -1 || link.indexOf('~VAL2~') != -1) {
      var strSplit = item.series.label.split(' ');
      var val1 = strSplit[0];
      var val2 = strSplit.length > 1 ? strSplit[1] : '';
      link = link.replace('~VAL1~', val1);
      link = link.replace('~VAL2~', val2);
    } else {
      var val = item.series.label;
      if (val.indexOf(' ') != -1) val = '"' + val + '"';
      link = link.replace('~VAL~', val);
    }
  }
  event.preventDefault();
  window.location.href = link;
}

function get_pie_chart(div, url) {
  tfm.tools.deprecate('window.get_pie_chart()', 'react DonutChart component', '2.5');
  if ($('#' + div).length == 0) {
    $('body').append(
      '<div id="' +
        div +
        '" class="modal fade"><div class="modal-dialog"><div class="modal-content"></div></div></div>'
    );
    $('#' + div + ' .modal-content')
      .append(
        '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title"></h4></div>'
      )
      .append('<div class="container">')
      .append(
        '<div id="' +
          div +
          '-body" class="modal-body"><div class="spinner spinner-lg modal-spinner"></div></div>'
      )
      .append('<div class="legend" ></div>')
      .append('</div>')
      .append('<div class="modal-footer"></div>');

    $('#' + div).modal('show');
    $('#' + div).on('shown.bs.modal', function() {
      $.getJSON(url, function(data) {
        var target = $('#' + div + '-body');
        target.empty();
        target.addClass('fact_chart');
        var hostsCount = 0;
        $.each(data.values, function() {
          hostsCount += this.data;
        });
        expanded_pie(target, data.values);
        $('.modal-title')
          .empty()
          .append(
            __('Fact distribution chart') +
              ' - <b>' +
              _.escape(data.name) +
              ' </b><small> (' +
              tfm.i18n.sprintf(
                n__('%s host', '%s hosts', hostsCount),
                hostsCount
              ) +
              ')</small>'
          );
        target.attr(
          'data-url',
          tfm.tools.foremanUrl('/hosts?search=facts.' + data.name + '~~VAL1~')
        );
      });
    });
  } else {
    $('#' + div).modal('show');
  }
}

function expand_chart(ref) {
  tfm.tools.deprecate('window.expand_chart()', 'react DonutChart component', '2.5');
  var chart = $(ref);
  if (!chart.hasClass('statistics-pie')) {
    chart = chart.parent().find('.statistics-pie');
  }
  var modal_id = chart[0].id + '_modal';
  if ($('#' + modal_id).length == 0) {
    var new_chart = chart
      .clone()
      .empty()
      .attr('id', modal_id + '_chart')
      .removeClass('small');
    $('body').append(
      '<div id="' +
        modal_id +
        '" class="modal fade"><div class="modal-dialog"><div class="modal-content"></div></div></div>'
    );
    $('#' + modal_id + ' .modal-content')
      .append(
        '<div class="modal-header"><a href="#" class="close" data-dismiss="modal">&times;</a><h3> ' +
          _.escape(chart.data('title')) +
          ' </h3></div>'
      )
      .append('<div class="modal-body"></div>');
    $('#' + modal_id + ' .modal-body').append(new_chart);
    expanded_pie(new_chart, new_chart.data('series'));
  }
  $('#' + modal_id).modal('show');
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
  $('.statistics-bar:visible').flot_bar();
  $('.statistics-pie:visible').flot_pie();
  $('.statistics-chart:visible').flot_chart();
}
