import React, { Component } from 'react';
import Downshift from 'downshift';
import { Dropdown, MenuItem, InputGroup, FormControl, Button } from 'patternfly-react';
import PropTypes from 'prop-types';

export const renderItems = ({
  items, highlightedIndex, selectedItem, getItemProps,
}) => (
  <Dropdown.Menu
    style={{
      display: 'block',
      position: 'absolute',
      left: 'inherit',
      marginTop: 0,
      top: 'auto',
    }}
  >
    {items.map((item, index) => (
      <MenuItem
        {...getItemProps({
          index,
          item,
          active: highlightedIndex === index,
          onClick: (e) => {
            // At this point the event.defaultPrevented
            // is already set to true by react-bootstrap
            // MenuItem. We need to set it back to false
            // So downshift will execute it's own handler
            e.defaultPrevented = false;
          },
        })}
        key={item}
      >
        {item}
      </MenuItem>
    ))}
  </Dropdown.Menu>
);

class AutoComplete extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inputValue: '',
    };
  }

  render() {
    const {
      onSearch, labelText, onInputUpdate, items, actionText, ...rest
    } = this.props;

    return (
      <Downshift
        onStateChange={({ inputValue }) => {
          if (typeof inputValue === 'string') {
            onInputUpdate(inputValue);
            this.setState({ inputValue });
          }
        }}
        defaultHighlightedIndex={0}
        selectedItem={this.state.inputValue}
        {...rest}
      >
        {({
          getInputProps,
          getItemProps,
          getLabelProps,
          isOpen,
          inputValue,
          highlightedIndex,
          getRootProps,
          selectedItem,
        }) => (
          <div>
            {labelText && <label {...getLabelProps()}>{labelText}</label>}
            <InputGroup>
              <FormControl type="text" {...getInputProps()} />
              <InputGroup.Button>
                <Button onClick={() => onSearch(inputValue)}>{actionText}</Button>
              </InputGroup.Button>
            </InputGroup>

            {isOpen && items.length
              ? renderItems({
                  items,
                  highlightedIndex,
                  selectedItem,
                  getItemProps,
                })
              : null}
          </div>
        )}
      </Downshift>
    );
  }
}

AutoComplete.propTypes = {
  items: PropTypes.arrayOf(PropTypes.string).isRequired,
  onInputUpdate: PropTypes.func.isRequired,
  onSearch: PropTypes.func.isRequired,
  labelText: PropTypes.string,
  actionText: PropTypes.string,
};

AutoComplete.defaultProps = {
  labelText: '',
  actionText: 'Search',
};

export default AutoComplete;
