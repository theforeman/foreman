import React from 'react';
import PropTypes from 'prop-types';
import { SplitButton, MenuItem, Button } from 'patternfly-react';

/**
 * Generate a button or a dropdown of buttons
 * @param  {String} title The title of the button for the title and text inside the button
 * @param  {Object} action action to preform when the button is click can be href with data-method or Onclick
 * @return {Function} button component or splitbutton component
 */
export const ActionButtons = ({ buttons }) => {
  if (!buttons.length) return null;
  if (buttons.length === 1)
    return (
      <Button bsSize="small" {...buttons[0].action}>
        {buttons[0].title}
      </Button>
    );
  const firstButton = buttons.shift();
  return (
    <SplitButton
      title={firstButton.title}
      {...firstButton.action}
      bsSize="small"
    >
      {buttons.map(button => (
        <MenuItem key={button.title} title={button.title} {...button.action}>
          {button.title}
        </MenuItem>
      ))}
    </SplitButton>
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
