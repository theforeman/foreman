import React from 'react';
import PropTypes from 'prop-types';
import { AreaChart as PfAreaChart } from 'patternfly-react';
import { getAreaChartConfig } from '../../../../../services/charts/AreaChartService';
import { noop } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import MessageBox from '../../MessageBox';

const AreaChart = ({
  data,
  onclick,
  noDataMsg,
  config,
  unloadData,
  xAxisDataLabel,
  yAxisLabel,
}) => {
  const chartConfig = getAreaChartConfig({
    data,
    config,
    onclick,
    yAxisLabel,
    xAxisDataLabel,
  });

  if (chartConfig.data.columns.length) {
    return <PfAreaChart {...chartConfig} unloadBeforeLoad={unloadData} />;
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};

AreaChart.propTypes = {
  data: PropTypes.arrayOf(PropTypes.array),
  onclick: PropTypes.func,
  noDataMsg: PropTypes.string,
  config: PropTypes.oneOf(['timeseries']),
  unloadData: PropTypes.bool,
  xAxisDataLabel: PropTypes.string,
  yAxisLabel: PropTypes.string,
};

AreaChart.defaultProps = {
  data: null,
  onclick: noop,
  noDataMsg: __('No data available'),
  config: 'timeseries',
  unloadData: false,
  xAxisDataLabel: 'time',
  yAxisLabel: '',
};

export default AreaChart;
