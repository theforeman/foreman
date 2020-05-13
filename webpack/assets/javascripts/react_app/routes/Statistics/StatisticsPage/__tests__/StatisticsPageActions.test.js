import API from '../../../../redux/API/API';

import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { getStatisticsMeta } from '../StatisticsPageActions';
import { statisticsProps, discussionUrl } from '../StatisticsPage.fixtures';

jest.mock('../../../../redux/API/API');

const runStatisticsAction = (callback, props, serverMock) => {
  API.get.mockImplementation(serverMock);

  return callback(props);
};

const fixtures = {
  'should fetch statisticsMeta': () =>
    runStatisticsAction(getStatisticsMeta, {}, async () => ({
      data: {
        charts: statisticsProps.statisticsMeta,
        discussion_url: discussionUrl,
      },
    })),
  'should fetch statisticsMeta and fail': () =>
    runStatisticsAction(getStatisticsMeta, {}, async () => {
      throw new Error('some-error');
    }),
};

describe('StatisticsPage actions', () =>
  testActionSnapshotWithFixtures(fixtures));
