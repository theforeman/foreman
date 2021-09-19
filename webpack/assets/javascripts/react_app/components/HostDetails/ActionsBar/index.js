import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Button,
  DropdownItem,
  DropdownSeparator,
  Dropdown,
  KebabToggle,
} from '@patternfly/react-core';
import { visit } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { foremanUrl } from '../../../common/helpers';

const ActionsBar = ({ hostId, permissions: { edit_hosts: canEdit } }) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);

  const dropdownItems = [
    <DropdownItem key="delete" component="button">
      {__('Delete')}
    </DropdownItem>,
    <DropdownItem key="clone" component="button">
      {__('Clone')}
    </DropdownItem>,
    <DropdownItem key="build" component="button">
      {__('Build')}
    </DropdownItem>,
    <DropdownSeparator key="separator" />,
    <DropdownItem key="[plugin]-action-1">
      {__('plugin action 1')}
    </DropdownItem>,
    <DropdownItem key="[plugin]-action-2" component="button">
      {__('plugin action 2')}
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
        toggle={<KebabToggle onToggle={onKebabToggle} />}
        isOpen={kebabIsOpen}
        isPlain
        dropdownItems={dropdownItems}
      />
    </>
  );
};

ActionsBar.propTypes = {
  hostId: PropTypes.string,
  permissions: PropTypes.object,
};
ActionsBar.defaultProps = {
  hostId: undefined,
  permissions: { edit_hosts: false },
};

export default ActionsBar;
