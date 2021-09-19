import { selectComponentByWeight } from '../../common/Slot/SlotSelectors';

export const selectKebabItems = () =>
  selectComponentByWeight('host-details-kebab');
