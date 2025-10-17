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
import './actionButtons.scss';

/**
 * Generate a button or a dropdown of buttons
 * @param  {Array} buttons The list of buttons to render.
 *   title: The title of the button for the title and text inside the button.
 *   action: The action to perform.
 *     onClick: function to call on click (safe to use)
 *     disabled: (True/False) if the button is disabled
 * @return {Function} button component or splitbutton with menu toggle action component
 */
export const ActionButtons = ({ buttons }) => {
  const [isOpen, setIsOpen] = useState(false);
  const onToggleClick = () => setIsOpen(!isOpen);

  if (!buttons.length) return null;
  if (buttons.length === 1)
    return (
      <Button
        ouiaId="action-button"
        size="sm"
        variant="primary"
        isDisabled={buttons[0].action?.disabled}
        {...buttons[0].action}
      >
        {buttons[0].title}
      </Button>
    );

  const [firstButton, ...restButtons] = buttons;

  return (
    <Dropdown
      ouiaId="action-buttons-dropdown}"
      isOpen={isOpen}
      onOpenChange={openState => setIsOpen(openState)}
      toggle={toggleRef => (
        <MenuToggle
          ref={toggleRef}
          onClick={onToggleClick}
          isExpanded={isOpen}
          splitButtonOptions={{
            variant: 'primary',
            items: [
              <MenuToggleAction
                id="split-action-toggle-button"
                key="split-action"
                onClick={firstButton.action?.onClick}
                isDisabled={firstButton.action?.disabled}
                aria-label={firstButton.title}
              >
                {firstButton.title}
              </MenuToggleAction>,
            ],
          }}
          aria-label="Menu toggle with action split button"
        />
      )}
      shouldFocusToggleOnSelect
    >
      <DropdownList className="action-buttons">
        {restButtons.map(button => (
          <DropdownItem
            ouiaId="dropdown-item"
            key={`${button.action?.id}-dropdown-item-key`}
            title={button.title}
            onClick={button.action?.onClick}
            isDisabled={button.action?.disabled}
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
      action: PropTypes.shape({
        id: PropTypes.number,
        onClick: PropTypes.func,
        disabled: PropTypes.bool,
      }),
      title: PropTypes.string,
    })
  ),
};

ActionButtons.defaultProps = {
  buttons: [],
};
