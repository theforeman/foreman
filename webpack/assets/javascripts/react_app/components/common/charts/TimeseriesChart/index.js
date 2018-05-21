import React from 'react';
import { LineChart as PfLineChart } from 'patternfly-react';
import { chartWithNoDataMessage } from '../common/chartWithNoDataMessage';
import { getTimeseriesChartConfig } from '../../../../../services/ChartService';

const TimeseriesChartWithNoDataMsgBox = chartWithNoDataMessage(PfLineChart);

const TimeseriesChart = ({
  data,
  type = 'line',
  unloadData = false,
  getConfig = getTimeseriesChartConfig,
}) => <TimeseriesChartWithNoDataMsgBox
       {...getConfig({ data, type })}
       unloadBeforeLoad = {unloadData}
      />;

export default TimeseriesChart;
