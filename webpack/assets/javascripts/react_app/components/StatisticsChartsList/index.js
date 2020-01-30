import React from 'react';
import PropTypes from 'prop-types';

import ConnectedChartBox from '../ChartBox';
import './StatisticsChartsListStyles.scss';
import { translate as __ } from '../../common/I18n';

const StatisticsChartsList = ({ data }) => {
  const chartBoxes = Object.values(data).map(chart => (
    <ConnectedChartBox
      key={chart.id}
      type="donut"
      chart={chart}
      noDataMsg={__('No data available')}
      tip={__('Expand the chart')}
    />
  ));

  return (
    <div className="statistics-charts-list-root cards-pf">{chartBoxes}</div>
  );
};

StatisticsChartsList.propTypes = {
  data: PropTypes.oneOfType([PropTypes.array, PropTypes.object]),
};

StatisticsChartsList.defaultProps = {
  data: [],
};

export default StatisticsChartsList;
