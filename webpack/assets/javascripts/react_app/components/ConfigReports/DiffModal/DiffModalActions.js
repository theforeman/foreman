import {
  DIFF_MODAL_TOGGLE,
  DIFF_MODAL_CREATE,
  DIFF_MODAL_VIEWTYPE,
} from './DiffModalConstants';

export const toggleModal = () => ({
  type: DIFF_MODAL_TOGGLE,
});

export const changeViewType = (viewType) => (dispatch) => {
  dispatch({
    type: DIFF_MODAL_VIEWTYPE,
    payload: {
      diffViewType: viewType,
    },
  });
};

export const createDiff = (diff, title) => (dispatch) => {
  dispatch({
    type: DIFF_MODAL_CREATE,
    payload: {
      diff,
      title,
      isOpen: true,
    },
  });
};
