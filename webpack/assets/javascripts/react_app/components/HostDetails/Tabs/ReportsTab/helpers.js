/* eslint-disable camelcase */
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { Button, FlexItem, Flex, Icon } from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core/deprecated';
import {
  ExclamationCircleIcon,
  SyncAltIcon,
  CheckCircleIcon,
  PendingIcon,
  AngleDoubleRightIcon,
} from '@patternfly/react-icons';
import { openConfirmModal } from '../../../ConfirmModal';
import { APIActions } from '../../../../redux/API';
import { sprintf, translate as __ } from '../../../../common/I18n';
import RelativeDateTime from '../../../common/dates/RelativeDateTime';

const statusMapper = {
  failed: amount => (
    <>
      <Icon color="var(--pf-v5-global--palette--red-100)">
        <ExclamationCircleIcon />
      </Icon>
      {amount}
    </>
  ),
  failed_restarts: amount => (
    <>
      <Icon color="var(--pf-v5-global--palette--red-100)">
        <SyncAltIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  restarted: amount => (
    <>
      <Icon color="var(--pf-v5-global--palette--orange-300)">
        <SyncAltIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  applied: amount => (
    <>
      <Icon color="var(--pf-v5-global--success-color--100)">
        <CheckCircleIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  skipped: amount => (
    <>
      <AngleDoubleRightIcon /> {amount}
    </>
  ),
  pending: amount => (
    <>
      <PendingIcon /> {amount}
    </>
  ),
};

export const statusFormatter = (statusName, response) => {
  const amount = response[statusName];
  if (!amount) return '--';
  return statusMapper[statusName](amount);
};

export const originFormatter = ({ origin: { src, label } }) =>
  src ? (
    <>
      <img
        alt={`${label}-icon`}
        src={src}
        style={{ width: '15px', marginBottom: '3px' }}
      />{' '}
      {label}
    </>
  ) : (
    '--'
  );

export const ActionFormatter = ({ id, can_delete }, fetchReports) => {
  const [isOpen, setOpen] = useState(false);
  const dispatch = useDispatch();
  const dispatchConfirm = () => {
    dispatch(
      openConfirmModal({
        isWarning: true,
        title: __('Delete report?'),
        confirmButtonText: __('Delete report'),
        onConfirm: () =>
          dispatch(
            APIActions.delete({
              url: `/api/v2/config_reports/${id}`,
              key: `report-${id}-DELETE`,
              successToast: success => __('Report was successfully deleted'),
              errorToast: error =>
                sprintf(
                  __('There was some issue deleting the report: %s'),
                  error
                ),
              handleSuccess: fetchReports,
            })
          ),
        message: __(
          'Are you sure you want to delete this report? This action is irreversible.'
        ),
      })
    );
  };
  const dropdownItems = [
    <DropdownItem
      ouiaId="action-dropdown-item"
      key="action"
      component="button"
      onClick={dispatchConfirm}
      disabled={!can_delete}
    >
      {__('Delete')}
    </DropdownItem>,
  ];
  return (
    <Flex>
      <FlexItem align={{ default: 'alignRight' }}>
        <Dropdown
          ouiaId="action-dropdown"
          onSelect={v => setOpen(!v)}
          toggle={
            <KebabToggle
              onToggle={(_event, val) => setOpen(val)}
              id="toggle-action"
            />
          }
          isOpen={isOpen}
          isPlain
          dropdownItems={dropdownItems}
        />
      </FlexItem>
    </Flex>
  );
};

export const reportToShowFormatter = ({ reported_at, can_view, id }) => (
  <Button
    ouiaId="report-to-show-button"
    variant="link"
    component="a"
    isInline
    isDisabled={!can_view}
    href={`/config_reports/${id}`}
  >
    <RelativeDateTime date={reported_at} />
  </Button>
);

export const getColumns = (fetchReports, origin) => {
  const columns = [
    {
      title: __('Reported at'),
      formatter: reportToShowFormatter,
    },
    {
      title: __('Failed'),
      formatter: response => statusFormatter('failed', response),
    },
    {
      title: __('Failed restarts'),
      formatter: response => statusFormatter('failed_restarts', response),
    },
    {
      title: __('Restarted'),
      formatter: response => statusFormatter('restarted', response),
    },
    {
      title: __('Applied'),
      formatter: response => statusFormatter('applied', response),
    },
    {
      title: __('Skipped'),
      formatter: response => statusFormatter('skipped', response),
    },
    {
      title: __('Pending'),
      formatter: response => statusFormatter('pending', response),
    },
    {
      title: null,
      formatter: data => ActionFormatter(data, fetchReports),
    },
  ];

  /** if the table is being filtered already with a specific origin,
   there is no need to show that origin column.
  */
  if (!origin) {
    columns.splice(-2, 0, {
      title: __('Origin'),
      formatter: originFormatter,
    });
  }

  return columns;
};
