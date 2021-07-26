import { registerFillComponent } from '../Fill/FillActions';
import store from '../../../redux';

export const addGlobalFill = (slotId, fillId, component, weight, metadata) => {
  store.dispatch(
    registerFillComponent(
      slotId,
      undefined,
      fillId,
      component,
      weight,
      metadata
    )
  );
};
