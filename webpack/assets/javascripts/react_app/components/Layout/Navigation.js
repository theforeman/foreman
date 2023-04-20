import React, { useEffect, useRef, useMemo } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  Nav,
  NavList,
  NavItem,
  NavExpandable,
  NavGroup,
  NavItemSeparator,
} from '@patternfly/react-core';
import { getCurrentPath } from './LayoutHelper';

const titleWithIcon = (title, iconClass) => (
  <div>
    <span className={classNames(iconClass, 'nav-title-icon')} />
    <span className="nav-title">{title}</span>
  </div>
);

const Navigation = ({
  items,
  navigationActiveItem,
  setNavigationActiveItem,
}) => {
  const clearTimerRef = useRef();
  useEffect(
    () => () => {
      if (clearTimerRef.current) clearTimeout(clearTimerRef.current);
    },
    []
  );

  const onMouseOver = index => {
    clearTimeout(clearTimerRef.current);
    if (navigationActiveItem !== index) {
      setNavigationActiveItem(index);
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

  const getGroupedItems = useMemo(
    () =>
      items.map(({ subItems, ...rest }) => {
        const { pathname } = window.location;
        const groups = [];
        let currIndex = 0;
        if (subItems.length) {
          if (subItems[0].isDivider) {
            groups.push({ title: subItems[0].title, groupItems: [] });
          } else {
            groups.push({ title: '', groupItems: [] });
          }
          subItems.forEach(sub => {
            if (sub.isDivider) {
              groups.push({ title: sub.title, groupItems: [] });
              currIndex++;
            } else {
              groups[currIndex].groupItems.push({
                ...sub,
                isActive: pathname === sub.href.split('?')[0],
              });
            }
          });
        }
        return { ...rest, groups };
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [items.length]
  );

  const groupedItems = getGroupedItems;
  return (
    <Nav id="foreman-nav">
      <NavList>
        {groupedItems.map(({ title, iconClass, groups, className }, index) => (
          <React.Fragment key={index}>
            <NavExpandable
              title={titleWithIcon(title, iconClass)}
              groupId="nav-expandable-group-1"
              isActive={
                subItemToItemMap[pathFragment(getCurrentPath())] === title
              }
              isExpanded={
                subItemToItemMap[pathFragment(getCurrentPath())] === title
              }
              className={className}
              onClick={() => onMouseOver(index)}
              onFocus={() => {
                onMouseOver(index);
              }}
            >
              {groups.map((group, groupIndex) =>
                groupIndex === 0 ? (
                  <NavGroup key={0} title={group.title}>
                    {group.groupItems.map(
                      (
                        {
                          id,
                          title: subItemTitle,
                          className: subItemClassName,
                          href,
                          onClick,
                          isActive,
                        },
                        groupItemsIndex
                      ) => (
                        <React.Fragment key={id}>
                          <NavItem
                            className={subItemClassName}
                            id={id}
                            to={href}
                            onClick={onClick}
                            isActive={isActive}
                          >
                            {subItemTitle}
                          </NavItem>
                          {groupItemsIndex !== group.groupItems.length - 1 && (
                            <NavItemSeparator />
                          )}
                        </React.Fragment>
                      )
                    )}
                  </NavGroup>
                ) : (
                  <React.Fragment key={groupIndex}>
                    <NavItemSeparator />
                    <NavExpandable
                      title={group.title}
                      isExpanded={group.groupItems.some(
                        ({ isActive }) => isActive
                      )}
                    >
                      {group.groupItems.map(
                        (
                          {
                            id,
                            title: subItemTitle,
                            className: subItemClassName,
                            href,
                            onClick,
                            isActive,
                          },
                          groupItemsIndex
                        ) => (
                          <React.Fragment key={id}>
                            <NavItem
                              className={subItemClassName}
                              id={id}
                              to={href}
                              onClick={onClick}
                              isActive={isActive}
                            >
                              {subItemTitle}
                            </NavItem>
                            {groupItemsIndex !==
                              group.groupItems.length - 1 && (
                              <NavItemSeparator />
                            )}
                          </React.Fragment>
                        )
                      )}
                    </NavExpandable>
                  </React.Fragment>
                )
              )}
            </NavExpandable>
          </React.Fragment>
        ))}
      </NavList>
    </Nav>
  );
};

Navigation.propTypes = {
  items: PropTypes.array.isRequired,
  navigationActiveItem: PropTypes.number,
  setNavigationActiveItem: PropTypes.func.isRequired,
};
Navigation.defaultProps = {
  navigationActiveItem: null,
};

export default Navigation;
