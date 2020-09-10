import uuidV1 from 'uuid/v1';
import { getChartConfig } from './ChartService';

export const getLineChartConfig = ({
  data,
  config,
  onclick,
  id = uuidV1(),
  xAxisDataLabel,
  axisOpts,
}) => {
  const chartConfig = getChartConfig({
    type: 'line',
    data,
    config,
    id,
    onclick,
  });

  if (chartConfig.data && chartConfig.data.columns) {
    chartConfig.data.columns = chartConfig.data.columns.map(col => {
      const [label, values] = col;
      // destruct data into format line chart accepts,
      // remove last item in column as it specifies the color
      return [label, ...values];
    });
  }

  if (config === 'timeseries' && xAxisDataLabel) {
    chartConfig.data.x = xAxisDataLabel;
  } else if (config === 'timeseries' && !xAxisDataLabel) {
    throw new Error('xAxisDataLabel is missing for timeseries line graph');
  }

  chartConfig.axis = { ...chartConfig.axis, ...axisOpts };

  delete chartConfig.tooltip;

  return chartConfig;
};
