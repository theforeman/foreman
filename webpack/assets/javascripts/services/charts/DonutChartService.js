import uuidV1 from 'uuid/v1';
import { getChartConfig, navigateToSearch } from './ChartService';

export const getDonutChartConfig = ({
  data,
  config,
  onclick,
  searchUrl,
  searchFilters,
  id = uuidV1(),
}) =>
  getChartConfig({
    type: 'donut',
    data,
    config,
    id,
    onclick: (d, element) => {
      if (onclick) onclick(d, element);
      if (searchUrl) navigateToSearch(searchUrl, searchFilters || {}, d);
    },
  });
