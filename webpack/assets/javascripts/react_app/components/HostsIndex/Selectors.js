import { selectComponentByWeight } from '../common/Slot/SlotSelectors';

export const selectKebabItems = () =>
  selectComponentByWeight('hosts-index-kebab');
