import React from 'react';
import PropTypes from 'prop-types';
import { DebounceInput } from 'react-debounce-input';
import { Icon } from 'patternfly-react';
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
        <Icon type="fa" name="search" />
        <DebounceInput
          className="form-control"
          inputRef={(input) => {
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
