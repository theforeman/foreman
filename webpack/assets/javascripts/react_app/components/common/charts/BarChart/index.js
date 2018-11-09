import React from 'react';
import PropTypes from 'prop-types';
import { BarChart as PfBarChart } from 'patternfly-react';
import { getBarChartConfig } from '../../../../../services/charts/BarChartService';
import { noop } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import MessageBox from '../../MessageBox';

const BarChart = ({
  data,
  onclick,
  noDataMsg,
  config,
  title,
  unloadData,
  xAxisLabel,
  yAxisLabel,
}) => {
  const chartConfig = getBarChartConfig({
    data,
    config,
    onclick,
    xAxisLabel,
    yAxisLabel,
  });

  if (chartConfig.data.columns.length) {
    return (
      <PfBarChart
        {...chartConfig}
        title={title}
        unloadBeforeLoad={unloadData}
      />
    );
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};

BarChart.propTypes = {
  data: PropTypes.arrayOf(PropTypes.array),
  onclick: PropTypes.func,
  noDataMsg: PropTypes.string,
  config: PropTypes.string,
  title: PropTypes.shape({
    type: PropTypes.string,
  }),
  unloadData: PropTypes.bool,
  xAxisLabel: PropTypes.string,
  yAxisLabel: PropTypes.string,
};

BarChart.defaultProps = {
  data: null,
  onclick: noop,
  noDataMsg: __('No data available'),
  config: 'regular',
  title: { type: 'percent' },
  unloadData: false,
  yAxisLabel: '',
  xAxisLabel: '',
};

export default BarChart;
