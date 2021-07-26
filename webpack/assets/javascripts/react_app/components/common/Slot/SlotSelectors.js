import SlotsRegistry from '../../../../services/SlotsRegistry';

export const selectComponentByWeight = slotId =>
  SlotsRegistry.getSlotComponents(slotId)
    .sort((a, b) => b.weight - a.weight)
    .map(c => c.component) || {};

export const selectMaxComponent = slotId => selectComponentByWeight(slotId)[0];

export const selectFillsAmount = (state, id) => {
  const registerdFills = state.extendable[id];
  return registerdFills ? Object.keys(registerdFills).length : 0;
};

export const selectFillsIDs = (state, id) => {
  const registerdFills = state.extendable[id];
  if (registerdFills) {
    const fillIDs = Object.keys(registerdFills);
    return fillIDs.sort(
      (a, b) => registerdFills[b].weight - registerdFills[a].weight
    );
  }
  return null;
};

export const selectFillsComponents = (state, props) => {
  const { id, multiple, fillID } = props;

  if (selectFillsAmount(state, id)) {
    if (fillID) {
      const slotComponent = SlotsRegistry.getSlotComponents(id);
      const getFill = slotComponent.filter(c => c.id === fillID);

      return [getFill[0].component];
    }
    if (multiple) return selectComponentByWeight(id);
    return [selectMaxComponent(id)];
  }
  return [];
};

export const selectSlotMetadata = (state, id) => {
  const registerdFills = state.extendable[id] || {};
  const slotMetadata = {};
  // eslint bug - https://github.com/eslint/eslint/issues/12117
  /* eslint-disable-next-line no-unused-vars */
  for (const fill of Object.keys(registerdFills)) {
    if (registerdFills[fill].metadata)
      slotMetadata[fill] = registerdFills[fill].metadata;
  }

  return slotMetadata;
};
