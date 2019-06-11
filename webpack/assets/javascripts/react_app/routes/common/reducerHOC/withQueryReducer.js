import Immutable from 'seamless-immutable';

const initialState = Immutable({
  page: 1,
  searchQuery: '',
  itemCount: 0,
});

const withQueryReducer = controller => (
  state = initialState,
  { type, payload }
) => {
  switch (type) {
    case `${controller}_UPDATE_QUERY`:
      return state.merge(payload);

    default:
      return state;
  }
};

export default withQueryReducer;
