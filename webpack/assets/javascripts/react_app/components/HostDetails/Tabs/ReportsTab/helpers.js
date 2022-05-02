/* eslint-disable camelcase */
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import {
  Button,
  Dropdown,
  DropdownItem,
  KebabToggle,
  FlexItem,
  Flex,
} from '@patternfly/react-core';
import {
  ExclamationCircleIcon,
  SyncAltIcon,
  CheckCircleIcon,
  PendingIcon,
  AngleDoubleRightIcon,
} from '@patternfly/react-icons';
import { openConfirmModal } from '../../../ConfirmModal';
import { APIActions } from '../../../../redux/API';
import { translate as __ } from '../../../../common/I18n';
import RelativeDateTime from '../../../common/dates/RelativeDateTime';
import PuppetPng from '../../../../../../images/Puppet.png';
import AnsiblePng from '../../../../../../images/Ansible.png';

const statusMapper = {
  failed: amount => (
    <>
      <ExclamationCircleIcon color="var(--pf-global--palette--red-100)" />{' '}
      {amount}
    </>
  ),
  failed_restarts: amount => (
    <>
      <SyncAltIcon color="var(--pf-global--palette--red-100)" /> {amount}
    </>
  ),
  restarted: amount => (
    <>
      <SyncAltIcon color="var(--pf-global--palette--orange-300)" /> {amount}
    </>
  ),
  applied: amount => (
    <>
      <CheckCircleIcon color="var(--pf-global--success-color--100)" /> {amount}
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

export const originFormatter = ({ origin }) => {
  const style = { width: '15px', marginBottom: '3px' };
  switch (origin) {
    case 'Puppet':
      return (
        <>
          <img alt="puppet-icon" src={PuppetPng} style={style} /> Puppet
        </>
      );
    case 'Ansible':
      return (
        <>
          <img alt="ansible-icon" src={AnsiblePng} style={style} /> Ansible
        </>
      );
    default:
      return (
        <>
          <img alt="ansible-icon" src={AnsiblePng} width="15" /> Ansible
        </>
      );
  }
};

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
                __(`There was some issue deleting the report: ${error}`),
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
          onSelect={v => setOpen(!v)}
          toggle={<KebabToggle onToggle={setOpen} id="toggle-action" />}
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
    variant="link"
    component="a"
    isInline
    isDisabled={!can_view}
    href={`/config_reports/${id}`}
  >
    <RelativeDateTime date={reported_at} />
  </Button>
);

export const getColumns = fetchReports => [
  {
    title: __('Reported at'),
    formatter: reportToShowFormatter,
    width: 20,
  },
  {
    title: __('Failed'),
    formatter: response => statusFormatter('failed', response),
    width: 10,
  },
  {
    title: __('Failed restarts'),
    formatter: response => statusFormatter('failed_restarts', response),
    width: 10,
  },
  {
    title: __('Restarted'),
    formatter: response => statusFormatter('restarted', response),
    width: 10,
  },
  {
    title: __('Applied'),
    formatter: response => statusFormatter('applied', response),
    width: 10,
  },
  {
    title: __('Skipped'),
    formatter: response => statusFormatter('skipped', response),
    width: 10,
  },
  {
    title: __('Pending'),
    formatter: response => statusFormatter('pending', response),
    width: 10,
  },
  {
    title: __('Origin'),
    formatter: originFormatter,
    width: 10,
  },
  {
    title: null,
    formatter: data => ActionFormatter(data, fetchReports),
    width: 10,
  },
];
