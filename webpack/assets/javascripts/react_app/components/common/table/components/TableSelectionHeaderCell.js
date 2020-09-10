import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { noop } from '../../../../common/helpers';

const TableSelectionHeaderCell = ({
  id,
  label,
  checked,
  onChange,
  ...props
}) => (
  <Table.SelectionHeading aria-label={label}>
    <Table.Checkbox
      id={id}
      title={label}
      checked={checked}
      onChange={onChange}
      {...props}
    />
  </Table.SelectionHeading>
);

TableSelectionHeaderCell.propTypes = {
  id: PropTypes.string,
  label: PropTypes.string,
  checked: PropTypes.bool,
  onChange: PropTypes.func,
};

TableSelectionHeaderCell.defaultProps = {
  id: 'selectAll',
  label: '',
  checked: false,
  onChange: noop,
};

export default TableSelectionHeaderCell;
