import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  isLoading: true,
  hasError: false,
  hasData: false,
  message: { type: 'empty', text: '' },
});

const withDataReducer = (controller, additionalState = Immutable({})) => (
  state = initialState.merge(additionalState),
  { type, payload }
) => {
  switch (type) {
    case `${controller}_DATA_RESOLVED`:
      return state.merge({ ...payload, isLoading: false });

    case `${controller}_DATA_FAILED`:
      return state.merge({ ...payload, isLoading: false, hasError: true });

    case `${controller}_CLEAR_ERROR`:
      return state.set('hasError', false);

    case `${controller}_SHOW_LOADING`:
      return state.set('isLoading', true);

    case `${controller}_HIDE_LOADING`:
      return state.set('isLoading', false);

    default:
      return state;
  }
};

export default withDataReducer;
