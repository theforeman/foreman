import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import {
  Dropdown,
  KebabToggle,
  DropdownItem,
} from '@patternfly/react-core/deprecated';

/**
 * Generate a button or a dropdown of buttons
 * @param  {String} title The title of the button for the title and text inside the button
 * @param  {Object} action action to preform when the button is click can be href with data-method or Onclick
 * @return {Function} button component or splitbutton component
 */
export const ActionButtons = ({ buttons: originalButtons }) => {
  const buttons = [...originalButtons];
  const [isOpen, setIsOpen] = useState(false);
  if (!buttons.length) return null;
  const firstButton = buttons.shift();
  return (
    <>
      <Button
        ouiaId="action-buttons-button"
        component={firstButton.action?.href ? 'a' : undefined}
        {...firstButton.action}
      >
        {firstButton.title}
      </Button>
      {buttons.length > 0 && (
        <Dropdown
          ouiaId="action-buttons-dropdown"
          toggle={
            <KebabToggle
              aria-label="toggle action dropdown"
              onToggle={(_event, val) => setIsOpen(val)}
            />
          }
          isOpen={isOpen}
          isPlain
          dropdownItems={buttons.map(button => (
            <DropdownItem
              ouiaId={`${button.title}-dropdown-item`}
              key={button.title}
              title={button.title}
              {...button.action}
            >
              {button.icon} {button.title}
            </DropdownItem>
          ))}
        />
      )}
    </>
  );
};

ActionButtons.propTypes = {
  buttons: PropTypes.arrayOf(
    PropTypes.shape({
      action: PropTypes.object,
      title: PropTypes.string,
      icon: PropTypes.node,
    })
  ),
};

ActionButtons.defaultProps = {
  buttons: [],
};
