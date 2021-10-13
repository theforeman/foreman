import uuidV1 from 'uuid/v1';
import { getChartConfig } from './ChartService';

export const getAreaChartConfig = ({
  data,
  config = 'timeseries',
  onclick,
  yAxisLabel,
  xAxisDataLabel = 'time',
  stacked = true,
  id = uuidV1(),
  size = undefined,
}) => {
  const chartConfig = getChartConfig({
    type: 'area',
    config,
    data,
    onclick,
    id,
  });

  if (config === 'timeseries' && xAxisDataLabel) {
    chartConfig.data.x = xAxisDataLabel;
  } else if (config === 'timeseries' && !xAxisDataLabel) {
    // eslint-disable-next-line no-console
    console.warn('xAxisDataLabel is missing for timeseries area graph');
  }

  if (data) {
    const timestamps = data[0].slice(1);
    const formatedDates = timestamps.map(
      (epochSecs) => new Date(epochSecs * 1000)
    );
    chartConfig.data.colors = {};
    chartConfig.data.columns[0] = [xAxisDataLabel].concat(formatedDates);
    if (size) {
      chartConfig.size = size;
    }

    if (stacked) {
      chartConfig.data.groups = [
        chartConfig.data.columns.slice(1).map((dataItem) => dataItem[0]),
      ];
    }
  }

  return {
    ...chartConfig,
    axis: {
      ...chartConfig.axis,
      y: {
        label: {
          text: yAxisLabel || null,
          position: 'outer-middle',
        },
      },
    },
  };
};
