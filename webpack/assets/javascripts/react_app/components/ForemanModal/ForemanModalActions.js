import {
  ADD_MODAL,
  SET_MODAL_OPEN,
  SET_MODAL_CLOSED,
  SET_MODAL_START_SUBMITTING,
  SET_MODAL_STOP_SUBMITTING,
} from './ForemanModalConstants';
import { selectModalExists } from './ForemanModalSelectors';

export const addModal =
  ({ id, isOpen = false, isSubmitting = false }) =>
  (dispatch, getState) =>
    dispatch({
      type: ADD_MODAL,
      payload: { id, isOpen, isSubmitting },
    });

const modalAction =
  (actionType) =>
  ({ id }) =>
  (dispatch, getState) => {
    if (!selectModalExists(getState(), id)) {
      // eslint-disable-next-line no-console
      console.warn(
        `${actionType} action received, but ForemanModal with id '${id}' does not exist.`
      );
    }
    return dispatch({
      type: actionType,
      payload: { id },
    });
  };

export const setModalStartSubmitting = modalAction(SET_MODAL_START_SUBMITTING);
export const setModalStopSubmitting = modalAction(SET_MODAL_STOP_SUBMITTING);
export const setModalOpen = modalAction(SET_MODAL_OPEN);
export const setModalClosed = modalAction(SET_MODAL_CLOSED);

// Pass in the ForemanModal id here and get bound action creators with the id already plugged in.
export const bindForemanModalActionsToId = ({ id }) => ({
  addModal: () => addModal({ id }),
  setModalOpen: () => setModalOpen({ id }),
  setModalClosed: () => setModalClosed({ id }),
  setModalStartSubmitting: () => setModalStartSubmitting({ id }),
  setModalStopSubmitting: () => setModalStopSubmitting({ id }),
});
