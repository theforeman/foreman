import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../../common/I18n';

const BooleanValue = ({ id, name, css, value, onChange }) => {
  const options = [
    { label: '', value: '' },
    { label: __('Yes'), value: 'true' },
    { label: __('No'), value: 'false' },
  ];
  return (
    <select
      id={id}
      name={name}
      className={`without_select2 ${css}`}
      onChange={e => onChange(e.target.value)}
      defaultValue={value}
    >
      {options.map(item => (
        <option value={item.value} key={item.value}>
          {item.label}
        </option>
      ))}
    </select>
  );
};

BooleanValue.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string.isRequired,
  css: PropTypes.string,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
};

BooleanValue.defaultProps = {
  id: '',
  css: '',
  value: false,
};

export default BooleanValue;
