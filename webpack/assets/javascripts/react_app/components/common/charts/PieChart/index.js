import React from 'react';
import {
  getPieChartConfig,
  setTitle,
} from '../../../../../services/ChartService';
import Chart from '../Chart';
require('./PieChart.scss');

export default ({ data, onclick }) => {
  const config = getPieChartConfig({ data, onclick });

  return (
    <Chart
      className="c3-statistics-pie small"
      setTitle={setTitle}
      config={config}
    />
  );
};
