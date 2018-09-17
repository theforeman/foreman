import React from 'react';
import { DebounceInput } from 'react-debounce-input';
import { Icon } from 'patternfly-react';
import './searchInput.scss';

class SearchInput extends React.Component {
  componentDidMount() {
    if (this.props.focus) {
      this.gainFocus();
    }
  }
  gainFocus() {
    this.nameInput.focus();
  }

  render() {
    const { onSearchChange, searchValue, timeout, onClear } = this.props;

    return (
      <div className="input-search">
        <Icon type="fa" name="search" />
        <DebounceInput
          className="form-control"
          inputRef={input => {
            this.nameInput = input;
          }}
          id="breadcrumbs-search"
          placeholder={__('filter...')}
          value={searchValue}
          minLength={0}
          debounceTimeout={timeout}
          onChange={onSearchChange}
        />
        <Icon type="fa" name="close" onClick={() => onClear()} />
      </div>
    );
  }
}

export default SearchInput;
