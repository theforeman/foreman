import uuidV1 from 'uuid/v1';
import { getDonutChartConfigPF5 } from './ChartService';

export const getDonutChartConfig = ({
  data,
  config,
  onclick,
  searchUrl,
  searchFilters,
  title,
  id = uuidV1(),
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
