import React from 'react';
import PropTypes from 'prop-types';
import { Icon } from 'patternfly-react';
import { noop } from '../../common/helpers';

class SelectInput extends React.Component {
  componentDidMount() {
    if (this.props.focus) this.nameInput.focus();
  }

  render() {
    const {
      searchValue,
      id,
      onClear,
      placeholder,
      onSearchChange,
      onKeyDown,
    } = this.props;

    return (
      <div className="select-input-search">
        <Icon type="fa" name="search" />
        <input
          autoComplete="off"
          className="form-control"
          ref={input => {
            this.nameInput = input;
          }}
          id={id}
          placeholder={placeholder}
          value={searchValue}
          onChange={onSearchChange}
          onKeyDown={onKeyDown}
        />
        <Icon type="fa" name="close" onClick={onClear} />
      </div>
    );
  }
}

SelectInput.propTypes = {
  focus: PropTypes.bool,
  searchValue: PropTypes.string,
  onSearchChange: PropTypes.func,
  onKeyDown: PropTypes.func,
  onClear: PropTypes.func,
  placeholder: PropTypes.string,
  id: PropTypes.string,
};

SelectInput.defaultProps = {
  focus: false,
  searchValue: '',
  onSearchChange: noop,
  onKeyDown: noop,
  onClear: noop,
  placeholder: 'Filter...',
  id: null,
};

export default SelectInput;
