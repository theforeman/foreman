import React from 'react';
import { DonutChart as PfDonutChart } from 'patternfly-react';
import { getDonutChartConfig } from '../../../../../services/ChartService';
import { chartWithNoDataMessage } from '../common/chartWithNoDataMessage';

const DonutChartWithNoDataMsgBox = chartWithNoDataMessage(PfDonutChart);

const DonutChart = ({
  data,
  onclick,
  config = 'regular',
  title = { type: 'percent' },
  unloadData = false,
  getConfig = getDonutChartConfig,
}) => <DonutChartWithNoDataMsgBox
          {...getConfig({ data, config, onclick })}
          title={title}
          unloadBeforeLoad = {unloadData}
         />;

export default DonutChart;
