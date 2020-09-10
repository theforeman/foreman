import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

const TableSelectionCell = ({ id, label, checked, onChange, ...props }) => (
  <Table.SelectionCell>
    <Table.Checkbox
      id={id}
      label={label}
      checked={checked}
      onChange={onChange}
      {...props}
    />
  </Table.SelectionCell>
);

TableSelectionCell.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string,
  checked: PropTypes.bool,
  onChange: PropTypes.func,
};

TableSelectionCell.defaultProps = {
  label: __('Select row'),
  checked: false,
  onChange: noop,
};

export default TableSelectionCell;
