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

  describe('addModal', () => {
    it('throws an error if the modal already exists', () => {
      expect(() => store.dispatch(addModal({ id: 'modal1' }))).toThrow(
        'already exists'
      );
    });
  });
  describe('setModalOpen', () => {
    it('throws an error if the modal does not exist', () => {
      expect(() => store.dispatch(setModalOpen({ id: 'modal42' }))).toThrow(
        'does not exist'
      );
    });
  });
  describe('setModalClosed', () => {
    it('throws an error if the modal does not exist', () => {
      expect(() => store.dispatch(setModalClosed({ id: 'modal42' }))).toThrow(
        'does not exist'
      );
    });
  });
});
