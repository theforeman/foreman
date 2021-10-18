import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import {
  Button,
  DropdownItem,
  DropdownSeparator,
  Dropdown,
  KebabToggle,
} from '@patternfly/react-core';
import {
  DatabaseIcon,
  TrashIcon,
  CloneIcon,
  CommentIcon,
  UndoIcon,
  FileInvoiceIcon,
} from '@patternfly/react-icons';
import { visit } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';
import { foremanUrl } from '../../../common/helpers';
import { deleteHost } from './actions';
import { useForemanSettings } from '../../../Root/Context/ForemanContext';

const ActionsBar = ({
  hostId,
  computeId,
  hasReports,
  permissions: {
    destroy_hosts: canDestroy,
    create_hosts: canCreate,
    edit_hosts: canEdit,
  },
}) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);
  const { destroyVmOnHostDelete } = useForemanSettings();
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const dispatch = useDispatch();
  const deleteHostHandler = () =>
    dispatch(deleteHost(hostId, computeId, destroyVmOnHostDelete));
  const dropdownItems = [
    <DropdownItem
      isDisabled={!canCreate}
      onClick={() => visit(foremanUrl(`/hosts/${hostId}/clone`))}
      key="clone"
      component="button"
      icon={<CloneIcon />}
    >
      {__('Clone')}
    </DropdownItem>,
    <DropdownItem
      isDisabled={!canDestroy}
      onClick={deleteHostHandler}
      key="delete"
      component="button"
      icon={<TrashIcon />}
    >
      {__('Delete')}
    </DropdownItem>,
    <DropdownSeparator />,
    <DropdownItem
      onClick={() => visit(foremanUrl(`/hosts/${hostId}/facts`))}
      key="fact"
      component="button"
      icon={<DatabaseIcon />}
    >
      {__('Facts')}
    </DropdownItem>,
    <DropdownItem
      isDisabled={!hasReports}
      onClick={() => visit(foremanUrl(`/hosts/${hostId}/config_reports`))}
      key="report"
      component="button"
      icon={<FileInvoiceIcon />}
    >
      {__('Reports')}
    </DropdownItem>,
    <DropdownSeparator />,
    <DropdownItem
      icon={<UndoIcon />}
      href={`/hosts/${hostId}`}
      key="prev-version"
    >
      {__('Previous UI')}
    </DropdownItem>,
    <DropdownItem
      icon={<CommentIcon />}
      onClick={() =>
        window.open(
          'https://community.theforeman.org/t/foreman-3-0-new-host-detail-page-feedback/25281',
          '_blank'
        )
      }
      key="feedback"
      component="button"
    >
      {__('Share feedback')}
    </DropdownItem>,
  ];

  return (
    <>
      <Button
        onClick={() => visit(foremanUrl(`/hosts/${hostId}/edit`))}
        variant="secondary"
        isDisabled={!canEdit}
      >
        {__('Edit')}
      </Button>
      <Dropdown
        alignments={{ default: 'right' }}
        toggle={<KebabToggle onToggle={onKebabToggle} />}
        isOpen={kebabIsOpen}
        isPlain
        dropdownItems={dropdownItems.concat(registeredItems)}
      />
    </>
  );
};

ActionsBar.propTypes = {
  hostId: PropTypes.string,
  computeId: PropTypes.number,
  permissions: PropTypes.object,
  hasReports: PropTypes.bool,
};
ActionsBar.defaultProps = {
  hostId: undefined,
  computeId: undefined,
  permissions: { destroy_hosts: false, create_hosts: false, edit_hosts: false },
  hasReports: false,
};

export default ActionsBar;
