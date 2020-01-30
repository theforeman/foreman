import { statisticsMeta } from '../../../components/StatisticsChartsList/StatisticsChartsList.fixtures';
import { noop } from '../../../common/helpers';

export const statisticsProps = {
  statisticsMeta,
  isLoading: false,
  hasData: true,
  hasError: false,
  message: {},
  getStatisticsMeta: noop,
};
