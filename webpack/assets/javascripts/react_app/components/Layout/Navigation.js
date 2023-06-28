import React, { useState, useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  Nav,
  NavList,
  NavItem,
  NavExpandable,
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
  navigate,
  items,
  navigationActiveItem,
  setNavigationActiveItem,
}) => {
  const [currentPath, setCurrentPath] = useState(window.location.pathname);
  useEffect(() => {
    const handleLocationChange = () => {
      setCurrentPath(window.location.pathname);
    };
    window.addEventListener('popstate', handleLocationChange);
    return () => {
      window.removeEventListener('popstate', handleLocationChange);
    };
  }, []);

  const onMouseOver = index => {
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

  const groupedItems = useMemo(
    () =>
      items.map(({ subItems, ...rest }) => {
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
                isActive: currentPath === sub.href.split('?')[0],
              });
            }
          });
        }
        return { ...rest, groups };
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [items.length, currentPath]
  );

  const clickAndNavigate = (_onClick, href, event) => {
    if (event.ctrlKey) return;
    event.preventDefault();
    if (_onClick && typeof _onClick === 'function') {
      _onClick();
    } else {
      navigate(href);
    }

    setCurrentPath(href);
  };
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
                  group.groupItems.map(
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
                          onClick={event =>
                            clickAndNavigate(onClick, href, event)
                          }
                          isActive={isActive}
                        >
                          {subItemTitle}
                        </NavItem>
                        {groupItemsIndex !== group.groupItems.length - 1 && (
                          <NavItemSeparator />
                        )}
                      </React.Fragment>
                    )
                  )
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
                              onClick={event =>
                                clickAndNavigate(onClick, href, event)
                              }
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
  navigate: PropTypes.func.isRequired,
  items: PropTypes.array.isRequired,
  navigationActiveItem: PropTypes.number,
  setNavigationActiveItem: PropTypes.func.isRequired,
};
Navigation.defaultProps = {
  navigationActiveItem: null,
};

export default Navigation;
