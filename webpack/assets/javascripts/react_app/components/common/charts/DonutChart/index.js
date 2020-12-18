import React from 'react';
import PropTypes from 'prop-types';
import { DonutChart as PfDonutChart } from 'patternfly-react';
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
  unloadData,
  searchUrl,
  searchFilters,
}) => {
  const chartConfig = getDonutChartConfig({
    data,
    config,
    onclick,
    searchUrl,
    searchFilters,
  });

  if (chartConfig.data.columns.length > 0) {
    return (
      <PfDonutChart
        {...chartConfig}
        title={title}
        unloadBeforeLoad={unloadData}
      />
    );
  }
  return <MessageBox msg={noDataMsg} icontype="info" />;
};

DonutChart.propTypes = {
  data: PropTypes.oneOfType([PropTypes.object, PropTypes.array]),
  config: PropTypes.oneOf(['regular', 'medium', 'large']),
  noDataMsg: PropTypes.string,
  title: PropTypes.object,
  unloadData: PropTypes.bool,
  onclick: PropTypes.func,
  searchUrl: PropTypes.string,
  searchFilters: PropTypes.object,
};

DonutChart.defaultProps = {
  data: undefined,
  config: 'regular',
  noDataMsg: __('No data available'),
  title: { type: 'percent', precision: 1 },
  unloadData: false,
  onclick: noop,
  searchUrl: undefined,
  searchFilters: undefined,
};

export default DonutChart;
