import React, { useState } from 'react';
import {
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
} from '@patternfly/react-core';
import { EllipsisVIcon, UndoIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../common/I18n';

export const LegacyUIKebab = () => {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <Dropdown
      // the id QE looks up is on the always-rendered container; the menu
      // (which carries ouiaId) only exists while open
      ouiaId="legacy-ui-kebab-menu"
      containerOuiaId="legacy-ui-kebab"
      id="legacy-ui-kebab"
      popperProps={{ position: 'right' }}
      isOpen={isOpen}
      onSelect={() => setIsOpen(false)}
      onOpenChange={newIsOpen => setIsOpen(newIsOpen)}
      toggle={toggleRef => (
        <MenuToggle
          ref={toggleRef}
          variant="plain"
          aria-label="legacy-ui-kebab-toggle"
          id="legacy-ui-kebab-toggle"
          ouiaId="legacy-ui-kebab-toggle"
          isExpanded={isOpen}
          onClick={() => setIsOpen(!isOpen)}
          icon={<EllipsisVIcon />}
        />
      )}
    >
      <DropdownList>
        <DropdownItem
          ouiaId="legacy-ui-link-dropdown-item"
          key="legacy-ui-link-dropdown-item"
          to="/hosts"
          icon={<UndoIcon />}
        >
          {__('Legacy UI')}
        </DropdownItem>
      </DropdownList>
    </Dropdown>
  );
};
