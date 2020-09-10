import { registerFillComponent } from '../Fill/FillActions';
import store from '../../../redux';

export const addGlobalFill = (slotId, fillId, component, weight) => {
  store.dispatch(
    registerFillComponent(slotId, undefined, fillId, component, weight)
  );
};
