/* eslint-disable camelcase */
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import {
  Button,
  Dropdown,
  DropdownItem,
  DropdownList,
  FlexItem,
  Flex,
  Icon,
  MenuToggle,
} from '@patternfly/react-core';
import {
  EllipsisVIcon,
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
import { ICON_CONTENT_COLOR_VARIABLE } from '../../../../constants';

const statusMapper = {
  failed: amount => (
    <>
      <Icon status="danger">
        <ExclamationCircleIcon />
      </Icon>
      {amount}
    </>
  ),
  failed_restarts: amount => (
    <>
      <Icon status="danger">
        <SyncAltIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  restarted: amount => (
    <>
      <Icon
        style={{
          [ICON_CONTENT_COLOR_VARIABLE]:
            'var(--pf-t--global--color--nonstatus--orange--default)',
        }}
      >
        <SyncAltIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  applied: amount => (
    <>
      <Icon status="success">
        <CheckCircleIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  skipped: amount => (
    <>
      <Icon>
        <AngleDoubleRightIcon />
      </Icon>{' '}
      {amount}
    </>
  ),
  pending: amount => (
    <>
      <Icon>
        <PendingIcon />
      </Icon>{' '}
      {amount}
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
  return (
    <Flex>
      <FlexItem align={{ default: 'alignRight' }}>
        <Dropdown
          ouiaId="action-dropdown-menu"
          containerOuiaId="action-dropdown"
          isOpen={isOpen}
          onSelect={() => setOpen(false)}
          onOpenChange={newIsOpen => setOpen(newIsOpen)}
          popperProps={{ position: 'right' }}
          toggle={toggleRef => (
            <MenuToggle
              ref={toggleRef}
              id="toggle-action"
              ouiaId="action-dropdown-toggle"
              variant="plain"
              aria-label={__('Actions')}
              isExpanded={isOpen}
              onClick={() => setOpen(!isOpen)}
              icon={<EllipsisVIcon />}
            />
          )}
        >
          <DropdownList>
            <DropdownItem
              ouiaId="action-dropdown-item"
              key="action"
              onClick={dispatchConfirm}
              isDisabled={!can_delete}
            >
              {__('Delete')}
            </DropdownItem>
          </DropdownList>
        </Dropdown>
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
    const ORIGIN_COLUMN_OFFSET = -2;
    columns.splice(ORIGIN_COLUMN_OFFSET, 0, {
      title: __('Origin'),
      formatter: originFormatter,
    });
  }

  return columns;
};
