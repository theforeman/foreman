import React from 'react';
import CommonForm from './CommonForm';
import $ from 'jquery';
import { map } from 'lodash';

class Select extends React.Component {
  componentDidMount() {
    if ($.fn.select2) {
      $(this.refs.select)
        .select2()
        .on('change', this.props.onChange);
    }
  }

  render() {
    const renderOptions = arr =>
      map(arr, (attribute, value) => {
        return (
          <option key={attribute} value={value}>
            {value}
          </option>
        );
      });

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
        ref="select"
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

export default Select;
