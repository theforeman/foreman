import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { Icon } from 'patternfly-react';
import { noop } from '../../common/helpers';

class SelectInput extends React.Component {
  constructor(props) {
    super(props);
    this.searchInput = React.createRef();
  }

  componentDidMount() {
    if (this.props.focus) this.searchInput.current.focus();
  }

  render() {
    const {
      id,
      onClear,
      className,
      onKeyDown,
      onChange,
      placeholder,
      searchValue,
    } = this.props;
    const classes = classNames('select-input-search', className);

    return (
      <div className={classes}>
        <Icon type="fa" name="search" />
        <input
          autoComplete="off"
          className="form-control"
          ref={this.searchInput}
          id={id}
          placeholder={placeholder}
          value={searchValue}
          onChange={onChange}
          onKeyDown={onKeyDown}
        />
        <Icon type="fa" name="close" onClick={onClear} />
      </div>
    );
  }
}

SelectInput.propTypes = {
  className: PropTypes.string,
  focus: PropTypes.bool,
  id: PropTypes.string,
  onClear: PropTypes.func,
  onKeyDown: PropTypes.func,
  onChange: PropTypes.func,
  placeholder: PropTypes.string,
  searchValue: PropTypes.string,
};

SelectInput.defaultProps = {
  className: null,
  focus: false,
  id: null,
  onClear: noop,
  onKeyDown: noop,
  onChange: noop,
  placeholder: 'Filter...',
  searchValue: '',
};

export default SelectInput;
