import React, { forwardRef } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

/**
 * PF6 DropdownItem/MenuItem spreads unknown props onto the wrapping <li>, so
 * attributes such as data-method (used by jquery-ujs) never reach the link.
 * Use the returned component as the item's `component` prop to render an <a>
 * that carries the href and the extra attributes.
 * @param {String} href - link target
 * @param {Object} attributes - extra attributes for the <a>, e.g. { 'data-method': 'post' }
 * @param {String} extraClassName - class added next to the PF menu item class
 * @return {React.Component} anchor component that forwards its ref
 */
// Same arguments must yield the same component type, otherwise React remounts
// the link on every render and the open menu loses keyboard focus.
const menuLinkCache = new Map();

export const createMenuLinkComponent = (
  href,
  attributes = {},
  extraClassName = ''
) => {
  const cacheKey = JSON.stringify([href, attributes, extraClassName]);
  if (menuLinkCache.has(cacheKey)) return menuLinkCache.get(cacheKey);

  const MenuLink = forwardRef(({ className, ...props }, ref) => (
    <a
      ref={ref}
      href={href}
      {...attributes}
      {...props}
      className={classNames(className, extraClassName)}
    />
  ));
  MenuLink.propTypes = { className: PropTypes.string };
  MenuLink.defaultProps = { className: '' };
  menuLinkCache.set(cacheKey, MenuLink);
  return MenuLink;
};
