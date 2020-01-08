import Immutable from 'seamless-immutable';
import { testReducerSnapshotWithFixtures } from '../../common/testHelpers';
import reducer from './ForemanModalReducer';
import {
  SET_MODAL_OPEN,
  SET_MODAL_CLOSED,
  ADD_MODAL,
  SET_MODAL_START_SUBMITTING,
  SET_MODAL_STOP_SUBMITTING,
} from './ForemanModalConstants';

const modalsState = Immutable({
  myModal: { isOpen: true, isSubmitting: true },
  yourModal: { isOpen: false, isSubmitting: false },
});

const fixtures = {
  'initial state': modalsState,
  'should handle SET_MODAL_OPEN action': {
    state: modalsState,
    action: { type: SET_MODAL_OPEN, payload: { id: 'myModal' } },
  },
  'should handle SET_MODAL_CLOSED action': {
    state: modalsState,
    action: { type: SET_MODAL_CLOSED, payload: { id: 'myModal' } },
  },
  'should add a modal with ADD_MODAL': {
    action: { type: ADD_MODAL, payload: { id: 'modal3' } },
  },
  'should add an already-open modal with ADD_MODAL': {
    action: { type: ADD_MODAL, payload: { id: 'modal4', isOpen: true } },
  },
  'should handle SET_MODAL_START_SUBMITTING action': {
    state: modalsState,
    action: { type: SET_MODAL_START_SUBMITTING, payload: { id: 'yourModal' } },
  },
  'should handle SET_MODAL_STOP_SUBMITTING action': {
    state: modalsState,
    action: { type: SET_MODAL_STOP_SUBMITTING, payload: { id: 'myModal' } },
  },
};

describe('ForemanModal reducer', () => {
  describe('ADD_MODAL', () => {
    it('does not create duplicate modals', () => {
      expect(
        reducer(modalsState, {
          type: ADD_MODAL,
          payload: { id: 'yourModal' },
        })
      ).toEqual(modalsState);
    });
    it('is idempotent and does not alter state of existing modal', () => {
      expect(
        reducer(modalsState, {
          type: ADD_MODAL,
          payload: { id: 'myModal', isOpen: false }, // try to add an already existing modal with a different open state
        })
      ).toEqual(modalsState);
    });
  });

  describe('snapshots', () =>
    testReducerSnapshotWithFixtures(reducer, fixtures));
});
