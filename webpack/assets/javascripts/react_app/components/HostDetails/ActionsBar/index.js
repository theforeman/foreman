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
import { visit } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';
import { foremanUrl } from '../../../common/helpers';

const ActionsBar = ({ hostId, permissions: { edit_hosts: canEdit } }) => {
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
    <DropdownItem href={`/hosts/${hostId}`} key="prev-version">
      {__('Previous version')}
    </DropdownItem>,
    <DropdownItem
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
  permissions: PropTypes.object,
};
ActionsBar.defaultProps = {
  hostId: undefined,
  permissions: { edit_hosts: false },
};

export default ActionsBar;
