const slotsRegistry = {};

export const add = (SlotId, fillId, component, weight, overrideProps) => {
  if (slotsRegistry[SlotId] === undefined) {
    slotsRegistry[SlotId] = {};
  }
  component = component || overrideProps;
  slotsRegistry[SlotId][fillId] = { component, weight, id: fillId };
};

export const remove = (SlotId, fillId) => {
  const slotItems = slotsRegistry[SlotId];

  delete slotItems[fillId];
};

export const getSlotComponents = id =>
  slotsRegistry[id] ? Object.values(slotsRegistry[id]) : [];

export const getFillsFromSlot = slotId => slotsRegistry[slotId];
