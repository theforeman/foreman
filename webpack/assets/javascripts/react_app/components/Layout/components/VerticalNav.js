import React from 'react';
import classNames from 'classnames';
import {
  Nav,
  NavExpandable,
  NavItem,
  NavList,
  NavItemSeparator,
} from '@patternfly/react-core';
import {
  getCurrentPath,
  layoutPropTypes,
  layoutDefaultProps,
} from '../LayoutHelper';
import './VerticalNav.scss';

const titleWithIcon = (title, iconClass) => (
  <React.Fragment>
    <span className={classNames(iconClass, 'nav-title-icon')} />
    <span className="nav-title">{title}</span>
  </React.Fragment>
);

const VerticalNav = ({ items, navigate, ...props }) => {
  const pathFragment = path => path.split('?')[0];

  const subItemToItemMap = {};
  items.forEach(item => {
    item.subItems.forEach(subItem => {
      if (!subItem.isDivider) {
        // don't keep the query parameters for the key
        subItemToItemMap[pathFragment(subItem.href)] = item.title;
      }
    });
  });

  return (
    <Nav {...props}>
      <NavList>
        {items.map(item => (
          <NavExpandable
            key={item.title}
            title={titleWithIcon(item.title, item.iconClass)}
            isActive={
              subItemToItemMap[pathFragment(getCurrentPath())] === item.title
            }
            isExpanded={
              subItemToItemMap[pathFragment(getCurrentPath())] === item.title
            }
            className={classNames('foreman-nav-expandable', item.className)}
          >
            {item.subItems.map(subItem =>
              subItem.isDivider ? (
                <NavItemSeparator key={subItem.id} />
              ) : (
                <NavItem
                  key={subItem.id || subItem.href}
                  preventDefault
                  onClick={() => {
                    subItem.onClick();
                    navigate(subItem.href);
                  }}
                  isActive={
                    subItem.isActive ||
                    pathFragment(subItem.href) ===
                      pathFragment(getCurrentPath())
                  }
                >
                  {subItem.title}
                </NavItem>
              )
            )}
          </NavExpandable>
        ))}
      </NavList>
    </Nav>
  );
};
VerticalNav.propTypes = {
  navigate: layoutPropTypes.navigate,
  items: layoutPropTypes.items,
};
VerticalNav.defaultProps = {
  items: layoutDefaultProps.items,
  navigate: layoutDefaultProps.navigate,
};
export default VerticalNav;
