import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import { testActionSnapshotWithFixtures } from '../../common/testHelpers';
import { addModal, setModalOpen, setModalClosed } from './ForemanModalActions';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);
const store = mockStore({
  foremanModals: {
    modal1: { isOpen: true },
    modal2: { isOpen: false },
  },
});

const fixtures = {
  'creates the modal': () => store.dispatch(addModal({ id: 'testModal' })),
  'should open modal': () => store.dispatch(setModalOpen({ id: 'modal2' })),
  'should close modal': () => store.dispatch(setModalClosed({ id: 'modal1' })),
};

describe('ForemanModal actions', () => {
  testActionSnapshotWithFixtures(fixtures);
});
