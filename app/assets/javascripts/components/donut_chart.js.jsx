var DonutChart = React.createClass({
  displayName: 'DonutChart',
  /*
     Creates a donut chart using c3 -
     see https://www.patternfly.org/patterns/donut-chart/

     [+id+] - ID for the element where the chart is rendered
     [+className] - CSS class(es) to be applied to the div where the chart is rendered
     [+columns+] - Array of tuples containing label, value. Values must sum 100%
     e.g. ['success', 40], ['failed', 60]
     [+groups+] - Set groups for the data for stacking.
     e.g. [['dataa', 'datab'],['datac']]
     [+colors+] - Array of HEX color codes for each group.
     Defaults to Patternfly palette.
  */

  propTypes: {
    className: React.PropTypes.string,
    colors: React.PropTypes.arrayOf(React.PropTypes.string),
    columns: React.PropTypes.arrayOf(React.PropTypes.array).isRequired,
    groups: React.PropTypes.arrayOf(React.PropTypes.array),
    id: React.PropTypes.string.isRequired
  },

  getDefaultProps: function() {
    return {
      className: 'col-md-3',
      colors: ['#3F9C35', '#C00', '#D1D1D1', '#EC7A08']
    };
  },

  componentDidMount: function() {
    this.generateDonutChart();
  },

  maxPercentage: function(columns) {
    var values = columns.map(function(subarray) { return subarray[1] });
    var max = Math.max.apply(Math, values);
    var sum = values.reduce(function(prev, curr) { return prev + curr });
    return Math.round(100 * max / sum);
  },

  maxLabel: function(columns) {
    var original = 0;
    var values = columns.map(function(subarray) { return subarray[1] });
    var max = Math.max.apply(Math, values);
    return columns[values.indexOf(max)][0].toLowerCase();
  },

  generateDonutChart: function() {
    var donutChartConfig = jQuery().c3ChartDefaults().getDefaultDonutConfig();
    donutChartConfig.bindto = '#' + this.chart_target.id;
    donutChartConfig.data = {
      type: "donut",
      columns: this.props.columns,
      groups: this.props.groups,
      order: null
    };
    donutChartConfig.color = this.props.colors;
    donutChartConfig.tooltip = {
      contents: function (d) {
        return '<span class="donut-tooltip-pf" style="white-space: nowrap;">' +
          Math.round(d[0].ratio * 100) + '% ' + d[0].name +
            '</span>';
      }
    };
    c3.generate(donutChartConfig);

    var donutChartTitle = d3.select(this.chart_target).select('text.c3-chart-arcs-title');
    donutChartTitle.text("");
    donutChartTitle.insert('tspan').text(this.maxPercentage(this.props.columns) + '%')
    .classed('donut-title-big-pf', true).attr('dy', 0).attr('x', 0);
    donutChartTitle.insert('tspan').text(this.maxLabel(this.props.columns))
    .classed('donut-title-small-pf', true).attr('dy', 20).attr('x', 0);
  },

  render: function() {
    return (
        <div>
            <div className={this.props.className}
                 id={this.props.id}
                 ref={c => this.chart_target = c}
            />
        </div>
    );
  },
});
