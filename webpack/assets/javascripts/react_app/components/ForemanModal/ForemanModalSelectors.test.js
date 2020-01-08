import { testSelectorsSnapshotWithFixtures } from '../../common/testHelpers';
import {
  selectForemanModalsState,
  selectModalStateById,
  selectIsModalOpen,
  selectIsModalSubmitting,
} from './ForemanModalSelectors';

const state = {
  foremanModals: {
    myModal: { isOpen: true, isSubmitting: true },
    yourModal: { isOpen: false, isSubmitting: false },
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
  'tells you if a modal is submitting': () =>
    selectIsModalSubmitting(state, 'myModal'),
};

describe('ForemanModal selectors', () => {
  testSelectorsSnapshotWithFixtures(fixtures);
});
