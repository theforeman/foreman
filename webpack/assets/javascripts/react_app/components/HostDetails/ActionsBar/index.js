import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Button,
  DropdownItem,
  DropdownSeparator,
  Dropdown,
  KebabToggle,
} from '@patternfly/react-core';
import { foremanUrl } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import ConsoleModal from '../Console';

const ActionsBar = ({
  hostName,
  permissions: { console_hosts: canViewConsole },
}) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const [console, setConsole] = useState();
  const onKebabToggle = isOpen => setKebab(isOpen);

  const dropdownItems = [
    <DropdownItem key="clone" component="button">
      {__('Delete')}
    </DropdownItem>,
    <DropdownItem key="clone" component="button">
      {__('Clone')}
    </DropdownItem>,
    <DropdownItem key="disabled link" component="button">
      {__('Build')}
    </DropdownItem>,
    <DropdownSeparator key="separator" />,
    <DropdownItem
      isDisabled={!canViewConsole}
      key="console"
      onClick={() => setConsole(true)}
    >
      {__('Console')}
    </DropdownItem>,
    <DropdownItem key="separated action" component="button">
      {__('plugin action 2')}
    </DropdownItem>,
  ];

  return (
    <>
      <Button
        onClick={() => {
          window.location = foremanUrl(`/hosts/${hostName}/edit`);
        }}
        variant="secondary"
      >
        {__('Edit')}
      </Button>

      <Dropdown
        toggle={<KebabToggle onToggle={onKebabToggle} />}
        isOpen={kebabIsOpen}
        isPlain
        dropdownItems={dropdownItems}
      />
      {console && (
        <ConsoleModal
          hostID={hostName}
          isOpen={console}
          onClose={() => setConsole(false)}
        />
      )}
    </>
  );
};

ActionsBar.propTypes = {
  hostName: PropTypes.string.isRequired,
  permissions: PropTypes.object,
};

ActionsBar.defaultProps = {
  permissions: {},
};

export default ActionsBar;
