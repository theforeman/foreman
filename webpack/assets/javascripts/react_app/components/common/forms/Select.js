import $ from 'jquery';
import { map } from 'lodash';
import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';

class Select extends React.Component {
  componentDidMount() {
    if ($.fn.select2) {
      $(this.select)
        .select2()
        .on('change', this.props.onChange);
    }
  }

  render() {
    const renderOptions = arr =>
      map(arr, (attribute, value) => (
        <option key={attribute} value={value}>
          {value}
        </option>
      ));

    const {
      label,
      className = '',
      value,
      onChange,
      options,
      disabled,
    } = this.props;

    const innerSelect = (
      <select
        disabled={disabled}
        ref={select => {
          this.select = select;
        }}
        className="form-control"
        value={value}
        onChange={onChange}
      >
        <option />
        {renderOptions(options)}
      </select>
    );

    if (!label) {
      return innerSelect;
    }
    return (
      <CommonForm label={label} className={`common-select ${className}`}>
        {innerSelect}
      </CommonForm>
    );
  }
}

Select.propTypes = {
  value: PropTypes.string,
  label: PropTypes.string,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  options: PropTypes.object,
  onChange: PropTypes.func,
};

Select.defaultProps = {
  value: '',
  label: '',
  className: '',
  disabled: false,
  options: {},
  onChange: noop,
};

export default Select;
