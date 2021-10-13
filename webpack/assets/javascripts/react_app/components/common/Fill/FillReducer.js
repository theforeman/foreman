import Immutable from 'seamless-immutable';

import { REGISTER_FILL, REMOVE_FILLED_COMPONENT } from './FillConstants';

const initialState = Immutable({});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case REGISTER_FILL:
      return state.setIn([payload.slotId, payload.fillId], payload.weight);

    case REMOVE_FILLED_COMPONENT:
      return state.update(payload.slotId, (fills) =>
        fills.without(payload.fillId)
      );
    default:
      return state;
  }
};
