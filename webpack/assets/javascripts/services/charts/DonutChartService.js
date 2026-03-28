import uuidV4 from 'uuid/v4';
import { getDonutChartConfigPF5 } from './ChartService';

export const getDonutChartConfig = ({
  data,
  config,
  onclick,
  searchUrl,
  searchFilters,
  title,
  id = uuidV4(),
}) =>
  getDonutChartConfigPF5({
    data,
    config,
    onclick,
    searchUrl,
    searchFilters,
    title,
    id,
  });
