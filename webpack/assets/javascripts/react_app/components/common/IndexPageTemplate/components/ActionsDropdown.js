import React, { useState } from 'react';
import { DropdownItem, KebabToggle, Dropdown } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import * as TableFormatters from './formatters';
import componentRegistry from '../../../componentRegistry';

const ActionsDropdown = ({ actions, reloadData }) => {
  const [open, setOpen] = useState(false);
  const [preventDropdownToggle, setPreventDropdownToggle] = useState(false);
  const toggleDropdown = () => {
    !preventDropdownToggle && setOpen(value => !value);
  };
  if (actions.length === 0) return null;
  const dropdownItems = actions.map(
    ({ component, props: mountedProps, disabled, path, label }) => {
      const childKey = JSON.stringify(mountedProps);
      if (component) {
        const ActualComponent =
          TableFormatters[component] ||
          componentRegistry.registry[component]?.type;

        if (ActualComponent) {
          return (
            <ActualComponent
              key={childKey}
              {...mountedProps}
              reloadData={reloadData}
              setPreventDropdownToggle={setPreventDropdownToggle}
            />
          );
        }
      }

      return (
        <DropdownItem key={path} isDisabled={disabled} href={path}>
          {label}
        </DropdownItem>
      );
    }
  );

  return (
    <>
      <Dropdown
        isPlain
        isOpen={open}
        onSelect={setOpen}
        dropdownItems={dropdownItems}
        toggle={<KebabToggle onToggle={toggleDropdown} />}
      />
    </>
  );
};

ActionsDropdown.propTypes = {
  actions: PropTypes.array,
  reloadData: PropTypes.func,
};

ActionsDropdown.defaultProps = {
  actions: [],
  reloadData: n => n,
};

export default ActionsDropdown;
