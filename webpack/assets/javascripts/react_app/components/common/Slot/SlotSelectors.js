import { getSlotComponents } from '../../../../services/SlotsRegistry';

export const selectComponentByWeight = slotId =>
  getSlotComponents(slotId)
    .sort((a, b) => b.weight - a.weight)
    .map(c => c.component);

export const selectMaxComponent = slotId => selectComponentByWeight(slotId)[0];

export const selectFillsAmount = (state, id) => {
  const registerdFills = state.extendable[id];
  return registerdFills ? Object.keys(registerdFills).length : 0;
};

export const selectFillsComponents = (state, props) => {
  const { id, multiple } = props;

  if (selectFillsAmount(state, id)) {
    if (multiple) return selectComponentByWeight(id);
    return [selectMaxComponent(id)];
  }
  return [];
};
