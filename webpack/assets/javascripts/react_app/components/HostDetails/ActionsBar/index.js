import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import {
  Button,
  DropdownItem,
  DropdownSeparator,
  Dropdown,
  KebabToggle,
} from '@patternfly/react-core';
import { foremanUrl } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';

const ActionsBar = ({ hostName }) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);
  const registeredItems = useSelector(selectKebabItems, shallowEqual);

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
        dropdownItems={dropdownItems.concat(registeredItems)}
      />
    </>
  );
};

ActionsBar.propTypes = {
  hostName: PropTypes.string,
};
ActionsBar.defaultProps = {
  hostName: undefined,
};

export default ActionsBar;
