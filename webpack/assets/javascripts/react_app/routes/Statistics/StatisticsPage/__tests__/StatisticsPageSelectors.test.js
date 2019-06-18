import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  selectStatisticsPage,
  selectStatisticsMetadata,
  selectStatisticsHasMetadata,
  selectStatisticsIsLoading,
  selectStatisticsMessage,
  selectStatisticsHasError,
} from '../StatisticsPageSelectors';
import { statisticsProps } from '../StatisticsPage.fixtures';

const state = {
  statisticsPage: {
    ...statisticsProps,
  },
};

const fixtures = {
  'should return StatisticsPage': () => selectStatisticsPage(state),
  'should return StatisticsHasMetadata': () =>
    selectStatisticsHasMetadata(state),
  'should return StatisticsPage statisticsMeta': () =>
    selectStatisticsMetadata(state),
  'should return StatisticsPage isLoading': () =>
    selectStatisticsIsLoading(state),
  'should return StatisticsPage Message': () => selectStatisticsMessage(state),
  'should return StatisticsPage hasError': () =>
    selectStatisticsHasError(state),
};

describe('StatisticsPage selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
