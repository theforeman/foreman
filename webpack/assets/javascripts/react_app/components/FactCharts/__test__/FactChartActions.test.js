import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { openModal, closeModal } from '../FactChartActions';
import { key, url, id, title } from '../FactChart.fixtures';

jest.unmock('../FactChartActions');

const fixtures = {
  'should open modal': () => openModal({ apiKey: key, apiUrl: url, id, title }),
  'should close modal': () => closeModal(id),
};

describe('FactCharts actions', () => testActionSnapshotWithFixtures(fixtures));
