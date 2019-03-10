const components = {};

export const add = (SlotId, fillId, component, weight, overrideProps) => {
  if (components[SlotId] === undefined) {
    components[SlotId] = [];
  }

  component = component || overrideProps;

  components[SlotId].push({ fillId, component, weight });
};

export const remove = (SlotId, fillId) => {
  const slotItems = components[SlotId];

  components[SlotId] = slotItems.filter(item => item.fillId !== fillId);
};

export const getComponentsBySlotId = id => components[id];
