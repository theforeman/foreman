const slotsRegistry = {};

export const add = (SlotId, fillId, component, weight, overrideProps) => {
  if (slotsRegistry[SlotId] === undefined) {
    slotsRegistry[SlotId] = {};
  }
  component = component || overrideProps;
  slotsRegistry[SlotId][fillId] = { component, weight };
};

export const remove = (SlotId, fillId) => {
  const slotItems = slotsRegistry[SlotId];

  delete slotItems[fillId];
};

export const getSlotComponents = id => Object.values(slotsRegistry[id]);
