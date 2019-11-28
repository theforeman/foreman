import { HOST_POWER_STATUS } from '../../../consts';
import { createAPIReducer } from '../../../API';

const onFailure = (state, payload) => {
  const {
    message: errorMessage,
    response: { data },
  } = payload.error;
  return state.set(data.id, { error: errorMessage, ...data });
};

export default createAPIReducer({
  key: HOST_POWER_STATUS,
  managedByID: true,
  onFailure,
});
