import React from 'react';
import PropTypes from 'prop-types';
import { Menu, MenuToggle, Popper } from '@patternfly/react-core';
import { EllipsisVIcon } from '@patternfly/react-icons';

/**
 * Generate a button or a dropdown of buttons
 * @param  {String} title The title of the button for the title and text inside the button
 * @param  {Object} action action to preform when the button is click can be href with data-method or Onclick
 * @return {Function} button component or splitbutton component
 */
export const ActionKebab = ({ items, menuOpen, setMenuOpen }) => {
  const containerRef = React.useRef();
  if (!items.length) return null;
  const menu = (
    <Menu
      containsFlyout
      ouiaId="hosts-index-actions-kebab"
      id="hosts-index-actions-kebab"
      onSelect={() => setMenuOpen(false)}
    >
      {items}
    </Menu>
  );

  const menuToggle = (
    <MenuToggle
      variant="plain"
      aria-label="plain kebab"
      onClick={() => setMenuOpen(prev => !prev)}
      isExpanded={menuOpen}
    >
      <EllipsisVIcon />
    </MenuToggle>
  );

  return (
    <div ref={containerRef}>
      <Popper
        trigger={menuToggle}
        popper={menu}
        appendTo={containerRef.current || undefined}
        isVisible={menuOpen}
        popperMatchesTriggerWidth={false}
      />
    </div>
  );
};

ActionKebab.propTypes = {
  items: PropTypes.arrayOf(PropTypes.node),
  menuOpen: PropTypes.bool.isRequired,
  setMenuOpen: PropTypes.func.isRequired,
};

ActionKebab.defaultProps = {
  items: [],
};
