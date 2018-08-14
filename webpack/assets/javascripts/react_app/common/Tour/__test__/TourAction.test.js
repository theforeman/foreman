import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  updateAsSeen,
  getTours,
  startRunnig,
  stopRunning,
  registerTour,
} from '../TourActions';
import API from '../../../API';

jest.mock('../../../API');

const fixtures = {
  'should getTours': () => getTours(),

  'should registerTour': () => registerTour('breadcrumbsTour'),

  'should startRunnig': () => startRunnig('breadcrumbsTour'),

  'should stopRunning': () => stopRunning('breadcrumbsTour'),

  'should updateAsSeen': () => updateAsSeen('breadcrumbsTour'),
};

describe('Layout actions', () => {
  API.get.mockImplementation(async () => ({
    data: { breadcrumbs: { alreadySeen: false } },
  }));

  API.post.mockImplementation(async () => ({
    data: 'sucess',
  }));
  testActionSnapshotWithFixtures(fixtures);
});
