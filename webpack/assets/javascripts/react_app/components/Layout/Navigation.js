import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  Nav,
  NavList,
  NavItem,
  MenuGroup,
  Divider,
  Menu,
  MenuContent,
  MenuList,
  MenuItem,
  Popper,
} from '@patternfly/react-core';
import { getCurrentPath } from './LayoutHelper';

const titleWithIcon = (title, iconClass) => (
  <div>
    <span className={classNames(iconClass, 'nav-title-icon')} />
    <span className="nav-title">{title}</span>
  </div>
);

const Navigation = ({ items, flyoutActiveItem, setFlyoutActiveItem }) => {
  const onDocumentClick = (event, triggerElement, popperElement) => {
    if (flyoutActiveItem) {
      // check if we clicked within the popper, if so don't do anything
      const isChild = popperElement && popperElement.contains(event.target);
      if (!isChild) {
        setFlyoutActiveItem(null);
        // clicked outside the popper
      }
    }
  };

  const onMouseOver = index => {
    if (flyoutActiveItem !== index) {
      setFlyoutActiveItem(index);
    }
  };

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

  const handleFlyout = (
    { key, target, stopPropagation, preventDefault },
    index
  ) => {
    if (key === ' ' || key === 'ArrowRight') {
      stopPropagation();
      preventDefault();
      if (flyoutActiveItem !== index) {
        setFlyoutActiveItem(index);
      }
    }

    if (key === 'Escape' || key === 'ArrowLeft') {
      setFlyoutActiveItem(null);
    }
  };

  const withPopper = (trigger, popper, index) => (
    <Popper
      onDocumentClick={onDocumentClick}
      trigger={trigger}
      popper={popper}
      placement="right-start"
      appendTo={document.body}
      isVisible={flyoutActiveItem === index}
    />
  );

  const groupedItems = items.map(({ subItems, ...rest }) => {
    const groups = [];
    let currIndex = 0;
    if (subItems[0].isDivider) {
      groups.push({ title: subItems[0].title, groupItems: [] });
    } else {
      groups.push({ title: rest.title, groupItems: [] });
    }
    subItems.forEach(sub => {
      if (sub.isDivider) {
        groups.push({ title: sub.title, groupItems: [] });
        currIndex++;
      } else {
        groups[currIndex].groupItems.push(sub);
      }
    });
    return { ...rest, groups };
  });
  return (
    <Nav>
      <NavList>
        {groupedItems.map(({ title, iconClass, groups, className }, index) =>
          withPopper(
            <NavItem
              key={index}
              className={className}
              flyout={<div> </div>}
              itemId={index}
              isActive={
                flyoutActiveItem === index ||
                subItemToItemMap[pathFragment(getCurrentPath())] === title
              }
            >
              <div
                onMouseOver={() => onMouseOver(index)}
                onKeyDown={e => handleFlyout(e, index)}
                onFocus={() => onMouseOver(index)}
              >
                {titleWithIcon(title, iconClass)}
              </div>
            </NavItem>,
            <Menu key={index} containsFlyout>
              <MenuContent>
                <MenuList>
                  {groups.map((group, groupIndex) => (
                    <>
                      {group.title && groupIndex !== 0 && (
                        <Divider key={group.id} />
                      )}
                      <MenuGroup key={group.id} label={group.title}>
                        {group.groupItems.map(
                          ({
                            id,
                            title: subItemTitle,
                            className: subItemClassName,
                            href,
                            preventHref,
                            onClick,
                          }) => (
                            <MenuItem
                              key={id}
                              className={subItemClassName}
                              id={id}
                              to={href}
                              onClick={onClick}
                            >
                              {subItemTitle}
                            </MenuItem>
                          )
                        )}
                      </MenuGroup>
                    </>
                  ))}
                </MenuList>
              </MenuContent>
            </Menu>,
            index
          )
        )}
      </NavList>
    </Nav>
  );
};

Navigation.propTypes = {
  items: PropTypes.array.isRequired,
  flyoutActiveItem: PropTypes.number,
  setFlyoutActiveItem: PropTypes.func.isRequired,
};
Navigation.defaultProps = {
  flyoutActiveItem: null,
};

export default Navigation;
