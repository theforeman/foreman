import uuidV1 from 'uuid/v1';
import { getChartConfig } from './ChartService';

export const getBarChartConfig = ({
  data,
  config,
  onclick,
  xAxisLabel,
  yAxisLabel,
  id = uuidV1(),
}) => {
  const chartConfig = getChartConfig({
    type: 'bar',
    data,
    config,
    onclick,
    id,
  });

  let categories = null;
  let columns = null;

  if (data) {
    categories = data.map((dataItem) => dataItem[0]);

    columns = data.map((x) => x[1]);

    columns.unshift(xAxisLabel);

    chartConfig.data.columns = [columns];
  }

  return {
    ...chartConfig,

    axis: {
      x: {
        categories,
        type: 'category',
        label: xAxisLabel || null,
      },
      y: {
        label: yAxisLabel || null,
      },
    },
  };
};
