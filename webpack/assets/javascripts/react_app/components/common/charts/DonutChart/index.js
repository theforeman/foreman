import React from 'react';
import { DonutChart as PfDonutChart } from 'patternfly-react';
import { getDonutChartConfig } from '../../../../../services/charts/DonutChartService';
import MessageBox from '../../MessageBox';
import { translate as __ } from '../../../../../react_app/common/I18n';

const DonutChart = ({
  data,
  onclick,
  config = 'regular',
  noDataMsg = __('No data available'),
  title = { type: 'percent' },
  unloadData = false,
}) => {
  const chartConfig = getDonutChartConfig({ data, config, onclick });

  if (chartConfig.data.columns.length > 0) {
    return <PfDonutChart {...chartConfig} title={title} unloadBeforeLoad={unloadData} />;
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};

export default DonutChart;
