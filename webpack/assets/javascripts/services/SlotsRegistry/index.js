import forceSingleton from '../../react_app/common/forceSingleton';

class SlotsRegistry {
  static registry = forceSingleton('slots_registry', () => ({}));
  static add = (SlotId, fillId, component, weight, overrideProps) => {
    if (this.registry[SlotId] === undefined) {
      this.registry[SlotId] = {};
    }
    component = component || overrideProps;
    this.registry[SlotId][fillId] = { component, weight, id: fillId };
  };
  static remove = (SlotId, fillId) => {
    const slotItems = this.registry[SlotId];

    delete slotItems[fillId];
  };

  static getSlotComponents = (id) =>
    this.registry[id] ? Object.values(this.registry[id]) : [];

  static getFillsFromSlot = (slotId) => this.registry[slotId];
}

export default SlotsRegistry;
