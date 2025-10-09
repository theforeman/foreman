import React from 'react';
import PropTypes from 'prop-types';
import { DebounceInput } from 'react-debounce-input';
import { Icon, Button } from '@patternfly/react-core';
import { SearchIcon, TimesIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../../react_app/common/I18n';
import { noop } from '../../../common/helpers';
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
        <Icon>
          <SearchIcon />
        </Icon>
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
        <Button
          variant="plain"
          onClick={() => onClear()}
          aria-label="Clear"
          ouiaId="clear-search-input-button"
        >
          <Icon>
            <TimesIcon />
          </Icon>
        </Button>
      </div>
    );
  }
}

SearchInput.propTypes = {
  focus: PropTypes.bool,
  searchValue: PropTypes.string,
  timeout: PropTypes.number,
  onSearchChange: PropTypes.func,
  onClear: PropTypes.func,
};

SearchInput.defaultProps = {
  focus: false,
  searchValue: '',
  timeout: 300,
  onSearchChange: noop,
  onClear: noop,
};

export default SearchInput;
