import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { getChartData, showModal, closeModal } from '../FactChartActions';

jest.unmock('../FactChartActions');

const fixtures = {
  'getChartData should return api get with url and id': () =>
    getChartData('url', 1),
  'should open modal': () => showModal(1, 'test title'),
  'should close modal': () => closeModal(1),
};

describe('FactCharts actions', () => testActionSnapshotWithFixtures(fixtures));
