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

const ActionsBar = ({ hostName }) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);

  const dropdownItems = [
    <DropdownItem key="clone" component="button">
      Delete
    </DropdownItem>,
    <DropdownItem key="clone" component="button">
      Clone
    </DropdownItem>,
    <DropdownItem key="disabled link" component="button">
      Build
    </DropdownItem>,
    <DropdownSeparator key="separator" />,
    <DropdownItem key="separated link"> plugin action 1</DropdownItem>,
    <DropdownItem key="separated action" component="button">
      plugin action 2
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
    </>
  );
};

ActionsBar.propTypes = {
  hostName: PropTypes.string.isRequired,
};

export default ActionsBar;
