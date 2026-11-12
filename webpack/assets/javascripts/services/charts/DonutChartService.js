import { v7 as uuidV7 } from 'uuid';
import { getDonutChartConfigPF5 } from './ChartService';

export const getDonutChartConfig = ({
  data,
  config,
  onclick,
  searchUrl,
  searchFilters,
  title,
  id = uuidV7(),
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
