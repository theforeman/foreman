import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
  MenuToggleAction,
} from '@patternfly/react-core';
import './ActionButtons.scss';

/**
 * Generate a button or a dropdown of buttons
 * @param  {String} title The title of the button for the title and text inside the button
 * @param  {Object} action action to preform when the button is click can be href with data-method or Onclick
 * @return {Function} button component or dropdown with menu toggle action component
 */
export const ActionButtons = ({ buttons }) => {
  const [isOpen, setIsOpen] = useState(false);
  if (!buttons.length) return null;
  const menuButtons = [...buttons];
  if (buttons.length === 1)
    return (
      <Button
        ouiaId="action-buttons-button"
        variant="secondary"
        size="sm"
        isDisabled={buttons[0].action?.disabled}
        component={buttons[0].action?.href ? 'a' : undefined}
        {...(({ disabled, ...rest }) => rest)(buttons[0].action || {})}
      >
        {buttons[0].title}
      </Button>
    );
  const firstButton = menuButtons.shift();
  return (
    <Dropdown
      ouiaId="action-buttons-dropdown"
      isOpen={isOpen}
      onOpenChange={nextOpen => setIsOpen(nextOpen)}
      toggle={toggleRef => (
        <MenuToggle
          ref={toggleRef}
          variant="secondary"
          aria-label="Menu toggle with action split button"
          isExpanded={isOpen}
          isDisabled={firstButton.action?.disabled}
          splitButtonOptions={{
            variant: 'action',
            items: [
              <MenuToggleAction
                key={firstButton.title}
                className="action-buttons-menu-toggle-action"
                aria-label={firstButton.title}
                isDisabled={firstButton.action?.disabled}
                {...(({ disabled, ...rest }) => rest)(firstButton.action || {})}
              >
                {firstButton.title}
              </MenuToggleAction>,
            ],
          }}
          onClick={() => setIsOpen(!isOpen)}
        />
      )}
    >
      <DropdownList>
        {menuButtons.map(button => (
          <DropdownItem
            ouiaId={`action-buttons-${button.title}-dropdown-item`}
            key={button.title}
            isDisabled={button.action?.disabled}
            component={button.action?.href ? 'a' : 'button'}
            {...(({ disabled, ...rest }) => rest)(button.action || {})}
          >
            {button.title}
          </DropdownItem>
        ))}
      </DropdownList>
    </Dropdown>
  );
};

ActionButtons.propTypes = {
  buttons: PropTypes.arrayOf(
    PropTypes.shape({
      action: PropTypes.object,
      title: PropTypes.string,
    })
  ),
};

ActionButtons.defaultProps = {
  buttons: [],
};
