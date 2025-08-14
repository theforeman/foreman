import PropTypes from 'prop-types';
import React, { useState, createContext } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import {
  Button,
  Split,
  SplitItem,
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
  Divider,
} from '@patternfly/react-core';
import {
  DatabaseIcon,
  TrashIcon,
  CloneIcon,
  UndoIcon,
  BuildIcon,
  TerminalIcon,
  EllipsisVIcon,
} from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';
import { visit, foremanUrl } from '../../../common/helpers';
import { cancelBuild, deleteHost, isHostTurnOn } from './actions';
import {
  useForemanSettings,
  useForemanHostsPageUrl,
} from '../../../Root/Context/ForemanContext';
import BuildModal from './BuildModal';
import Slot from '../../common/Slot';

import forceSingleton from '../../../common/forceSingleton';

export const ForemanActionsBarContext = forceSingleton(
  'ActionsBarContext',
  () => createContext()
);

const ActionsBar = ({
  hostId,
  hostFriendlyId,
  hostName,
  computeId,
  isBuild,
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
  const hostsIndexUrl = useForemanHostsPageUrl();
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const isHostActive = useSelector(isHostTurnOn);

  const dispatch = useDispatch();
  const deleteHostHandler = () =>
    dispatch(
      deleteHost(hostName, computeId, destroyVmOnHostDelete, hostsIndexUrl)
    );

  const isConsoleDisabled = !(computeId && isHostActive);
  const determineTooltip = () => {
    if (isConsoleDisabled) {
      if (computeId) {
        return __('Console disabled as the host is powered off.');
      }
      return __('Compute resource does not support the console function.');
    }
    return undefined;
  };
  const buildHandler = () => {
    if (isBuild) {
      dispatch(cancelBuild(hostId, hostName));
      setKebab(false);
    } else {
      setBuildModal(true);
    }
  };
  const dropdownItems = [
    <DropdownItem
      ouiaId="build-dropdown-item"
      onClick={buildHandler}
      key="build"
      component="button"
      isDisabled={!canBuild}
      icon={<BuildIcon />}
    >
      {isBuild ? __('Cancel build') : __('Build')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="clone-dropdown-item"
      isDisabled={!canCreate}
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/clone`))}
      key="clone"
      component="button"
      icon={<CloneIcon />}
    >
      {__('Clone')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="delete-dropdown-item"
      isDisabled={!canDestroy}
      onClick={deleteHostHandler}
      key="delete"
      component="button"
      icon={<TrashIcon />}
    >
      {__('Delete')}
    </DropdownItem>,
    <Divider key="sp-1" component="li" />,
    <DropdownItem
      ouiaId="console-dropdown-item"
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/console`))}
      key="console"
      isAriaDisabled={isConsoleDisabled}
      tooltip={determineTooltip()}
      component="button"
      icon={<TerminalIcon />}
    >
      {__('Console')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="fact-dropdown-item"
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/facts`))}
      key="fact"
      component="button"
      icon={<DatabaseIcon />}
    >
      {__('Facts')}
    </DropdownItem>,
    <Divider key="sp-2" component="li" />,
    <DropdownItem
      ouiaId="pre-version-dropdown-item"
      icon={<UndoIcon />}
      to={`/hosts/${hostFriendlyId}`}
      key="prev-version"
    >
      {__('Legacy UI')}
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
            ouiaId="host-edit-button"
            onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/edit`))}
            variant="secondary"
            isDisabled={!canEdit}
          >
            {__('Edit')}
          </Button>
          <ForemanActionsBarContext.Provider value={{ onKebabToggle }}>
            <Dropdown
              ouiaId="kebab-dropdown"
              isOpen={kebabIsOpen}
              onOpenChange={isOpen => onKebabToggle(isOpen)}
              popperProps={{ position: 'right' }}
              toggle={toggleRef => (
                <MenuToggle
                  ref={toggleRef}
                  id="hostdetails-kebab"
                  variant="plain"
                  isExpanded={kebabIsOpen}
                  onClick={() => onKebabToggle(!kebabIsOpen)}
                >
                  <EllipsisVIcon />
                </MenuToggle>
              )}
            >
              <DropdownList>
                {dropdownItems.concat(registeredItems)}
              </DropdownList>
            </Dropdown>
          </ForemanActionsBarContext.Provider>
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
  isBuild: false,
};

export default ActionsBar;
