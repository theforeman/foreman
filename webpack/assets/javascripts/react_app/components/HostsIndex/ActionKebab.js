import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, KebabToggle } from '@patternfly/react-core';

/**
 * Generate a button or a dropdown of buttons
 * @param  {String} title The title of the button for the title and text inside the button
 * @param  {Object} action action to preform when the button is click can be href with data-method or Onclick
 * @return {Function} button component or splitbutton component
 */
export const ActionKebab = ({ items }) => {
  const [isOpen, setIsOpen] = useState(false);
  if (!items.length) return null;
  return (
    <>
      {items.length > 0 && (
        <Dropdown
          ouiaId="action-buttons-dropdown"
          toggle={
            <KebabToggle
              aria-label="toggle action dropdown"
              onToggle={setIsOpen}
            />
          }
          isOpen={isOpen}
          isPlain
          dropdownItems={items}
        />
      )}
    </>
  );
};

ActionKebab.propTypes = {
  items: PropTypes.arrayOf(PropTypes.node),
};

ActionKebab.defaultProps = {
  items: [],
};
