import PropTypes from 'prop-types';
import React from 'react';
import { useDispatch } from 'react-redux';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import StatusIcon from './StatusIcon';
import { forgetStatus } from './StatusActions';
import { translate as __, sprintf } from '../../../common/I18n';
import './styles.scss';
import { openConfirmModal } from '../../ConfirmModal';

const StatusTable = ({ hostName, statuses, canForgetStatuses }) => {
  const dispatch = useDispatch();
  const handleClearStatus = (event, rowId, rowData) => {
    const statusName = rowData[0]?.title?.props?.children || rowData[0];
    dispatch(
      openConfirmModal({
        title: __('Clear host status'),
        message: sprintf(
          __('You are about to clear the %s status. Are you sure?'),
          statusName
        ),
        isWarning: true,
        onConfirm: () => {
          const [chosenStatus] = statuses.filter(
            status => status.name === statusName
          );
          dispatch(forgetStatus(hostName, chosenStatus));
        },
      })
    );
  };
  const columns = [__('Name'), __('Status'), __('Reported at')];
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

  const actionResolver = () => [
    {
      title: __('Clear'),
      onClick: handleClearStatus,
      isDisabled: !canForgetStatuses,
    },
  ];

  const areActionsDisabled = (rowData, { rowIndex }) =>
    !statuses[rowIndex].reported_at;

  return (
    <Table
      style={{ height: 'auto' }}
      aria-label="statuses-table"
      ouiaId="statuses-table"
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
  hostName: PropTypes.string.isRequired,
  statuses: PropTypes.arrayOf(PropTypes.object),
  canForgetStatuses: PropTypes.bool,
};

StatusTable.defaultProps = {
  statuses: [],
  canForgetStatuses: undefined,
};

export default StatusTable;
