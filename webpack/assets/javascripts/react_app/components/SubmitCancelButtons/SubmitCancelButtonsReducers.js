import Immutable from 'seamless-immutable';
import { SUBMIT_CLICKED, SUBMIT_AND_CANCEL_RESET, CANCEL_CLICKED } from './SubmitCancelButtonsConsts';

const initState = Immutable({ submitting: false, disabled: false });

export default (state = initState, action) => {
  switch (action.type) {
    case SUBMIT_CLICKED:
      return state.merge({ submitting: true, disabled: true });
    case CANCEL_CLICKED:
      return state.merge({ submitting: false, disabled: true });
    case SUBMIT_AND_CANCEL_RESET:
      return state.merge({ submitting: false, disabled: false });
    default:
      return state;
  }
};
