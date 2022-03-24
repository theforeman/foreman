import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import {
  Button,
  DropdownItem,
  Dropdown,
  DropdownSeparator,
  KebabToggle,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import {
  DatabaseIcon,
  TrashIcon,
  CloneIcon,
  CommentIcon,
  UndoIcon,
  FileInvoiceIcon,
  BuildIcon,
  TerminalIcon,
} from '@patternfly/react-icons';
import { visit } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';
import { foremanUrl } from '../../../common/helpers';
import { cancelBuild, deleteHost, isHostTurnOn } from './actions';
import { useForemanSettings } from '../../../Root/Context/ForemanContext';
import BuildModal from './BuildModal';
import Slot from '../../common/Slot';

const ActionsBar = ({
  hostId,
  hostFriendlyId,
  hostName,
  computeId,
  isBuild,
  hasReports,
  permissions: {
    destroy_hosts: canDestroy,
    create_hosts: canCreate,
    edit_hosts: canEdit,
    build_hosts: canBuild,
  },
}) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const [isBuildModalOpen, setBuildModal] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);
  const { destroyVmOnHostDelete } = useForemanSettings();
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const isHostActive = useSelector(isHostTurnOn);

  const dispatch = useDispatch();
  const deleteHostHandler = () =>
    dispatch(deleteHost(hostId, computeId, destroyVmOnHostDelete));

  const buildHandler = () => {
    if (isBuild) {
      dispatch(cancelBuild(hostId));
      setKebab(false);
    } else {
      setBuildModal(true);
    }
  };
  const dropdownItems = [
    <DropdownItem
      onClick={buildHandler}
      key="build"
      component="button"
      isDisabled={!canBuild}
      icon={<BuildIcon />}
    >
      {isBuild ? __('Cancel build') : __('Build')}
    </DropdownItem>,
    <DropdownItem
      isDisabled={!canCreate}
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/clone`))}
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
    <DropdownSeparator key="sp-1" />,
    <DropdownItem
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/console`))}
      key="console"
      isDisabled={!isHostActive}
      component="button"
      icon={<TerminalIcon />}
    >
      {__('Console')}
    </DropdownItem>,
    <DropdownItem
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/facts`))}
      key="fact"
      component="button"
      icon={<DatabaseIcon />}
    >
      {__('Facts')}
    </DropdownItem>,
    <DropdownItem
      isDisabled={!hasReports}
      onClick={() =>
        visit(foremanUrl(`/hosts/${hostFriendlyId}/config_reports`))
      }
      key="report"
      component="button"
      icon={<FileInvoiceIcon />}
    >
      {__('Reports')}
    </DropdownItem>,
    <DropdownSeparator key="sp-2" />,
    <DropdownItem
      icon={<UndoIcon />}
      href={`/hosts/${hostFriendlyId}`}
      key="prev-version"
    >
      {__('Legacy UI')}
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
      <Split hasGutter>
        <SplitItem>
          <Slot hostId={hostId} hostName={hostName} id="_rex-host-features" />
        </SplitItem>
        <SplitItem>
          <Button
            onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/edit`))}
            variant="secondary"
            isDisabled={!canEdit}
          >
            {__('Edit')}
          </Button>
          <Dropdown
            alignments={{ default: 'right' }}
            toggle={
              <KebabToggle id="hostdetails-kebab" onToggle={onKebabToggle} />
            }
            isOpen={kebabIsOpen}
            isPlain
            dropdownItems={dropdownItems.concat(registeredItems)}
          />
        </SplitItem>
      </Split>
      {isBuildModalOpen && (
        <BuildModal
          isModalOpen={isBuildModalOpen}
          onClose={() => setBuildModal(false)}
          hostFriendlyId={hostFriendlyId}
          hostName={hostName}
        />
      )}
    </>
  );
};

ActionsBar.propTypes = {
  hostId: PropTypes.number,
  hostFriendlyId: PropTypes.string,
  hostName: PropTypes.string,
  computeId: PropTypes.number,
  permissions: PropTypes.object,
  hasReports: PropTypes.bool,
  isBuild: PropTypes.bool,
};
ActionsBar.defaultProps = {
  hostId: undefined,
  hostFriendlyId: undefined,
  hostName: undefined,
  computeId: undefined,
  permissions: {
    destroy_hosts: false,
    create_hosts: false,
    edit_hosts: false,
    build_hosts: false,
  },
  hasReports: false,
  isBuild: false,
};

export default ActionsBar;
