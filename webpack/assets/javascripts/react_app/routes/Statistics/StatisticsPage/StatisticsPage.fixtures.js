import { statisticsMeta } from '../../../components/StatisticsChartsList/StatisticsChartsList.fixtures';
import { noop } from '../../../common/helpers';

export const discussionUrl =
  '/links/forums?post=t/trends-and-statistics-plugin/18745/4';

export const statisticsProps = {
  statisticsMeta,
  discussionUrl,
  isLoading: false,
  hasData: true,
  hasError: false,
  message: {},
  getStatisticsMeta: noop,
};
