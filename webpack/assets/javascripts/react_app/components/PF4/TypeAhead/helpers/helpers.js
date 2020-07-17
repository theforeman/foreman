import { KEYCODES } from '../../../../common/keyCodes';

const keyPressHandler = (
  e,
  isOpen,
  activeItems,
  highlightedIndex,
  selectItem,
  userInputValue,
  onSearch
) => {
  switch (e.keyCode) {
    case KEYCODES.TAB_KEY:
      if (isOpen && activeItems[highlightedIndex]) {
        selectItem(activeItems[highlightedIndex]);
        e.preventDefault();
      }
      break;

    case KEYCODES.ENTER:
      if (!isOpen || !activeItems[highlightedIndex]) {
        onSearch(userInputValue);
        e.preventDefault();
      }
      break;

    default:
      break;
  }
};

export const getActiveItems = items =>
  items
    .filter(
      ({ disabled, type }) => !disabled && !['header', 'divider'].includes(type)
    )
    .map(({ text }) => text);

export default keyPressHandler;
