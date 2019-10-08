import { testSelectorsSnapshotWithFixtures } from '../../common/testHelpers';
import {
  selectForemanModalsState,
  selectModalStateById,
  selectIsModalOpen,
} from './ForemanModalSelectors';

const state = {
  foremanModals: {
    myModal: { open: true },
    yourModal: { open: false },
  },
};

const fixtures = {
  'selects entire modals state': () => selectForemanModalsState(state),
  'selects specific modal by id': () => selectModalStateById(state, 'myModal'),
  'tells you if a modal is open by id': () =>
    selectIsModalOpen(state, 'myModal'),
  'tells you if a modal is closed by id': () =>
    selectIsModalOpen(state, 'yourModal'),
  'returns undefined for a nonexistent modal': () =>
    selectIsModalOpen(state, 'noModal'),
};

describe('ForemanModal selectors', () => {
  testSelectorsSnapshotWithFixtures(fixtures);
});
