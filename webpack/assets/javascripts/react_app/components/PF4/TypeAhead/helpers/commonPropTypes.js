import PropTypes from 'prop-types';

const commonSearchPropTypes = {
  userInputValue: PropTypes.string.isRequired,
  clearSearch: PropTypes.func.isRequired,
  getInputProps: PropTypes.func.isRequired,
  getItemProps: PropTypes.func.isRequired,
  isOpen: PropTypes.bool.isRequired,
  inputValue: PropTypes.string.isRequired,
  highlightedIndex: PropTypes.number.isRequired,
  selectedItem: PropTypes.string.isRequired,
  selectItem: PropTypes.func.isRequired,
  openMenu: PropTypes.func.isRequired,
  onSearch: PropTypes.func.isRequired,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      text: PropTypes.string,
    })
  ).isRequired,
  activeItems: PropTypes.arrayOf(PropTypes.string).isRequired,
  shouldShowItems: PropTypes.bool.isRequired,
};

export const commonInputPropTypes = {
  passedProps: PropTypes.shape({}).isRequired,
  onKeyPress: PropTypes.func.isRequired,
  onInputFocus: PropTypes.func.isRequired,
};

export const commonItemPropTypes = {
  items: PropTypes.arrayOf(PropTypes.object).isRequired,
  activeItems: PropTypes.arrayOf(PropTypes.string).isRequired,
  highlightedIndex: PropTypes.number.isRequired,
  getItemProps: PropTypes.func.isRequired,
};

export default commonSearchPropTypes;
