import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';
import { deprecate } from '../../../../common/DeprecationService';

const TableSelectionCell = ({ id, label, checked, onChange, ...props }) => {
  useEffect(() => {
    deprecate(
      'table/components/TableSelectionCell',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  return (
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
};

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
