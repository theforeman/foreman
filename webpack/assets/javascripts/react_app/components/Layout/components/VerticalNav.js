import React from 'react';
import {
  Nav,
  NavExpandable,
  NavItem,
  NavItemSeparator,
  NavList,
} from '@patternfly/react-core';
import {
  getCurrentPath,
  handleMenuClick,
  layoutPropTypes,
  layoutDefaultProps,
} from '../LayoutHelper';

// checkPropTypes will throw a warning:
// Warning: Failed prop type: Invalid prop `title` of type `object` supplied to `NavExpandable`, expected `string`.
// This is expected until PatternFly is updated to accept ReactNode instead of just string for the title
const titleWithIcon = (title, iconClass) => (
  <React.Fragment>
    <span
      className={iconClass}
      style={{ pointerEvents: 'none', paddingRight: '10px' }}
    />
    <span style={{ pointerEvents: 'none' }}>{title}</span>
  </React.Fragment>
);

const VerticalNav = ({
  items,
  activeMenu,
  changeActiveMenu,
  history,
  ...props
}) => {
  const pathFragment = path => path.split('?')[0];

  // the pages outside of React don't have activeMenu information.
  // workaround is to build our own mapping that we can reference for the nav
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
    <Nav theme="dark" {...props}>
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
            className="foreman-nav-expandable"
          >
            {item.subItems.map(subItem =>
              subItem.isDivider ? (
                <NavItemSeparator key={subItem.id} />
              ) : (
                <NavItem
                  key={subItem.id || subItem.href}
                  preventDefault
                  onClick={() => {
                    handleMenuClick(item, activeMenu, changeActiveMenu);
                    history.push(subItem.href);
                  }}
                  isActive={
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
  activeMenu: layoutPropTypes.activeMenu,
  changeActiveMenu: layoutPropTypes.changeActiveMenu,
  history: layoutPropTypes.history.isRequired,
  items: layoutPropTypes.items,
};
VerticalNav.defaultProps = {
  activeMenu: layoutDefaultProps.activeMenu,
  changeActiveMenu: layoutDefaultProps.changeActiveMenu,
  items: layoutDefaultProps.items,
};
export default VerticalNav;
