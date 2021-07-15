import PropTypes from 'prop-types';
import React from 'react';
import { useDispatch } from 'react-redux';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import StatusIcon from './StatusIcon';
import { forgetStatus } from './StatusActions';
import { translate as __, sprintf } from '../../../common/I18n';
import './styles.scss';

const StatusTable = ({ hostName, statuses }) => {
  const dispatch = useDispatch();
  const handleClearStatus = (event, rowId, rowData) => {
    const statusName = rowData[0]?.title?.props?.children || rowData[0];
    // TODO: change with confirm dialog service
    const isConfirmed = window.confirm(
      sprintf(__('You are about to clear %s status. Are you sure?'), statusName)
    );
    if (isConfirmed) {
      const [chosenStatus] = statuses.filter(
        status => status.name === statusName
      );
      dispatch(forgetStatus(hostName, chosenStatus));
    }
  };
  const columns = [__('Name'), __('Status'), __('Reported At')];
  const rows = statuses?.map(
    ({ name, label, link, global, reported_at: reportedAt }) => [
      link ? { title: <a href={link}>{name}</a> } : name,
      { title: <StatusIcon statusNumber={global} label={label} /> },
      {
        title: (
          <RelativeDateTime
            date={reportedAt}
            defaultValue={<span className="disabled">{__('N/A')}</span>}
          />
        ),
      },
    ]
  );

  const actionResolver = (rowData, { rowIndex }) => {
    const { canClear } = statuses[rowIndex];
    return [
      { title: __('Clear'), onClick: handleClearStatus, isDisabled: !canClear },
    ];
  };

  const areActionsDisabled = (rowData, { rowIndex }) =>
    !statuses[rowIndex].reported_at;

  return (
    <Table
      style={{ height: 'auto' }}
      aria-label="statuses-table"
      variant="compact"
      borders="compactBorderless"
      cells={columns}
      rows={rows}
      dropdownDirection="up"
      actionResolver={actionResolver}
      areActionsDisabled={areActionsDisabled}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
};

StatusTable.propTypes = {
  hostName: PropTypes.string,
  statuses: PropTypes.arrayOf(PropTypes.object),
};

StatusTable.defaultProps = {
  hostName: '',
  statuses: [],
};

export default StatusTable;
