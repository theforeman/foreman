import {
  ADD_MODAL,
  SET_MODAL_OPEN,
  SET_MODAL_CLOSED,
} from './ForemanModalConstants';
import { selectModalStateById } from './ForemanModalSelectors';

export const addModal = ({ id, open = false }) => (dispatch, getState) => {
  const modalAlreadyExists = selectModalStateById(getState(), id);
  if (modalAlreadyExists) {
    throw new Error(`ForemanModal with ID ${id} already exists`);
  }
  return dispatch({
    type: ADD_MODAL,
    payload: { id, open },
  });
};

export const setModalOpen = ({ id }) => (dispatch, getState) => {
  const modalExists = selectModalStateById(getState(), id);
  if (!modalExists) {
    throw new Error(
      `SET_MODAL_OPEN error: Modal with id '${id}' does not exist`
    );
  }
  return dispatch({
    type: SET_MODAL_OPEN,
    payload: { id },
  });
};

export const setModalClosed = ({ id }) => (dispatch, getState) => {
  const modalExists = selectModalStateById(getState(), id);
  if (!modalExists) {
    throw new Error(
      `SET_MODAL_CLOSED error: Modal with id '${id}' does not exist`
    );
  }
  return dispatch({
    type: SET_MODAL_CLOSED,
    payload: { id },
  });
};

// Pass in the ForemanModal id here and get bound action creators with the id already plugged in.
export const bindForemanModalActionsToId = ({ id }) => ({
  addModal: () => addModal({ id }),
  setModalOpen: () => setModalOpen({ id }),
  setModalClosed: () => setModalClosed({ id }),
});
