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

export const selectFillsIDs = (state, id) => {
  const registerdFills = state.extendable[id];
  if (registerdFills) {
    const fillIDs = Object.keys(registerdFills);
    return fillIDs.sort((a, b) => registerdFills[b] - registerdFills[a]);
  }
  return null;
};

export const selectFillsComponents = (state, props) => {
  const { id, multiple, fillID } = props;

  if (selectFillsAmount(state, id)) {
    if (fillID) {
      const slotComponent = getSlotComponents(id);
      const getFill = slotComponent.filter(c => c.id === fillID);

      return [getFill[0].component];
    }
    if (multiple) return selectComponentByWeight(id);
    return [selectMaxComponent(id)];
  }
  return [];
};
