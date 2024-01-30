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
import { NavigationSearch } from './NavigationSearch';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../Root/Context/ForemanContext';

const titleWithIcon = (title, iconClass) => (
  <div className="nav-title-icon">
    <span className={classNames(iconClass, 'nav-icon')} />
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
      if (!subItem.isDivider && subItem.href) {
        // don't keep the query parameters for the key
        subItemToItemMap[pathFragment(subItem.href)] = item.title;
      }
    });
  });

  const currentLocation = useForemanLocation()?.title;
  const currentOrganization = useForemanOrganization()?.title;

  const groupedItems = useMemo(
    () =>
      items.map(({ className, subItems, ...rest }) => {
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
              const isCurrentLocation =
                className.includes('location-menu') &&
                (sub.title === currentLocation ||
                  (currentLocation === undefined &&
                    sub.id === 'menu_item_any_location'));
              const isCurrentOrganization =
                className.includes('organization-menu') &&
                (sub.title === currentOrganization ||
                  (currentOrganization === undefined &&
                    sub.id === 'menu_item_any_organization'));

              groups[currIndex].groupItems.push({
                ...sub,
                isActive:
                  (currentPath && currentPath === sub.href?.split('?')[0]) ||
                  isCurrentLocation ||
                  isCurrentOrganization,
              });
            }
          });
        }
        return { ...rest, groups, className };
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [items, currentPath, currentLocation, currentOrganization]
  );

  const [currentExpandedSecondary, setCurrentExpandedSecondary] = useState(
    null
  );
  const [currentExpanded, setCurrentExpanded] = useState(
    subItemToItemMap[pathFragment(getCurrentPath())]
  );
  useEffect(() => {
    setCurrentExpanded(subItemToItemMap[pathFragment(getCurrentPath())]);
    groupedItems.some(({ groups }) =>
      groups.some(({ groupItems, title }) =>
        groupItems.some(({ href }) => {
          if (href === pathFragment(getCurrentPath())) {
            setCurrentExpandedSecondary(title);
            return true;
          }
          return false;
        })
      )
    );
    // we only want to run this when we get new items from the API to set the default expanded item, which is the current location
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [items.length]);
  if (!items.length) return null;

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
    <Nav id="foreman-nav" ouiaId="foreman-nav">
      <NavList>
        <NavigationSearch clickAndNavigate={clickAndNavigate} items={items} />
        {groupedItems.map(({ title, iconClass, groups, className }, index) => (
          <React.Fragment key={index}>
            <NavExpandable
              ouiaId={`nav-expandable-${index}`}
              title={titleWithIcon(title, iconClass)}
              groupId={`nav-expandable-group-${title}`}
              isActive={
                subItemToItemMap[pathFragment(getCurrentPath())] === title
              }
              isExpanded={currentExpanded === title}
              className={className}
              onClick={() => onMouseOver(index)}
              onFocus={() => {
                onMouseOver(index);
              }}
              onExpand={() => {
                // if the current expanded item is the same as the clicked item, collapse it
                const isExpanded = currentExpanded === title;
                // close the Secondary nav if it's open
                if (isExpanded) setCurrentExpandedSecondary(null);
                // only have 1 item expanded at a time
                setCurrentExpanded(isExpanded ? null : title);
                setCurrentExpandedSecondary(null);
              }}
            >
              {groups.map((group, groupIndex) =>
                groupIndex === 0 ? (
                  group.groupItems.map(
                    ({
                      id,
                      title: subItemTitle,
                      className: subItemClassName,
                      href,
                      onClick,
                      isActive,
                    }) => (
                      <React.Fragment key={id}>
                        <NavItem
                          ouiaId={`nav-item-${id}`}
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
                      </React.Fragment>
                    )
                  )
                ) : (
                  <React.Fragment key={groupIndex}>
                    <NavItemSeparator />
                    <NavExpandable
                      ouiaId={`nav-expandable-${index}-${groupIndex}`}
                      title={group.title}
                      isExpanded={currentExpandedSecondary === group.title}
                      onExpand={() => {
                        setCurrentExpandedSecondary(
                          currentExpandedSecondary === group.title
                            ? null
                            : group.title
                        );
                      }}
                    >
                      {group.groupItems.map(
                        ({
                          id,
                          title: subItemTitle,
                          className: subItemClassName,
                          href,
                          onClick,
                          isActive,
                        }) => (
                          <React.Fragment key={id}>
                            <NavItem
                              ouiaId={`nav-item-${id}`}
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
