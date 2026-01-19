import React from 'react';
import PropTypes from 'prop-types';
import {
  ChartDonut,
  ChartThemeColor,
  ChartTooltip,
} from '@patternfly/react-charts';
import { getDonutChartConfig } from '../../../../../services/charts/DonutChartService';
import MessageBox from '../../MessageBox';
import { translate as __ } from '../../../../../react_app/common/I18n';
import { noop } from '../../../../common/helpers';

const DonutChart = ({
  data,
  onclick,
  config,
  noDataMsg,
  title,
  searchUrl,
  searchFilters,
}) => {
  const chartConfig = getDonutChartConfig({
    data,
    config,
    onclick,
    searchUrl,
    searchFilters,
    title,
  });

  if (chartConfig.data && chartConfig.data.length > 0) {
    const {
      data: chartData,
      colorScale,
      width,
      height,
      padding,
      innerRadius,
      labels,
      events,
      legendData,
    } = chartConfig;

    // Calculate title values for display based on title prop
    const total = chartData.reduce((sum, item) => sum + item.y, 0);
    let titleText = '';
    let subtitleText = '';

    if (title) {
      if (title.type === 'percent' && chartData.length > 0) {
        // Find the largest value for percentage calculation
        const maxItem = chartData.reduce(
          (max, item) => (item.y > max.y ? item : max),
          chartData[0]
        );
        const percentage =
          total > 0
            ? ((maxItem.y / total) * 100).toFixed(title.precision ?? 1)
            : 0;
        titleText = `${percentage}%`;
        subtitleText = title.secondary || maxItem.x;
      } else if (title.primary) {
        titleText = title.primary;
        subtitleText = title.secondary || '';
      }
    }

    return (
      <div className="donut-chart-pf" style={{ height, width, margin: 'auto' }}>
        <ChartDonut
          ariaDesc="Donut chart"
          constrainToVisibleArea
          data={chartData}
          height={height}
          width={width}
          padding={padding}
          innerRadius={innerRadius}
          colorScale={colorScale}
          labels={labels}
          labelComponent={<ChartTooltip constrainToVisibleArea />}
          events={events}
          legendData={legendData}
          themeColor={ChartThemeColor.multiOrdered}
          title={titleText}
          subTitle={subtitleText}
        />
      </div>
    );
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};

DonutChart.propTypes = {
  data: PropTypes.oneOfType([PropTypes.object, PropTypes.array]),
  config: PropTypes.oneOf(['regular', 'medium', 'large']),
  noDataMsg: PropTypes.string,
  title: PropTypes.object,
  onclick: PropTypes.func,
  searchUrl: PropTypes.string,
  searchFilters: PropTypes.object,
};

DonutChart.defaultProps = {
  data: undefined,
  config: 'regular',
  noDataMsg: __('No data available'),
  title: { type: 'percent', precision: 1 },
  onclick: noop,
  searchUrl: undefined,
  searchFilters: undefined,
};

export default DonutChart;
