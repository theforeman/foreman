import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { noop } from '../../../../common/helpers';
import { deprecate } from '../../../../common/DeprecationService';

const TableSelectionHeaderCell = ({
  id,
  label,
  checked,
  onChange,
  ...props
}) => {
  useEffect(() => {
    deprecate(
      'table/components/TableSelectionHeaderCell',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  return (
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
};

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
