import { createSelector } from 'reselect';
import { orderBy } from 'lodash';
import { getComponentsBySlotId } from '../Fill/ExtendableRegistery';

export const selectAllFills = slotId => getComponentsBySlotId(slotId);

export const selectComponentByWeight = createSelector(
  selectAllFills,
  fills => orderBy(fills, ['weight'], ['desc']).map(c => c.component)
);

export const selectMaxComponent = createSelector(
  selectComponentByWeight,
  fills => fills[0]
);

export const selectRegisteredFills = (state, slotId) =>
  state.extendable.RegisteredComponent[slotId] || {};
