import { createSelector } from 'reselect';
import { get, snakeCase } from 'lodash';
import { noop } from '../../common/helpers';

export const selectLayout = state => state.layout;

export const selectMenuItems = state => selectLayout(state).items;
export const selectActiveMenu = state => selectLayout(state).activeMenu;
export const selectIsLoading = state => selectLayout(state).isLoading;
export const selectIsCollapsed = state => selectLayout(state).isCollapsed;
export const selectCurrentLocation = state =>
  get(selectLayout(state), 'currentLocation.title');
export const selectCurrentOrganization = state =>
  get(selectLayout(state), 'currentOrganization.title');

export const patternflyMenuItemsSelector = createSelector(
  selectMenuItems,
  selectCurrentLocation,
  selectCurrentOrganization,
  (items, currentLocation, currentOrganization) =>
    patternflyItems(items, currentLocation, currentOrganization)
);

const childToMenuItem = (child, currentLocation, currentOrganization) => ({
  id: `menu_item_${snakeCase(child.name)}`,
  title: child.name,
  isDivider: child.type === 'divider',
  className:
    child.name === currentLocation || child.name === currentOrganization
      ? 'mobile-active'
      : '',
  href: child.url || '#',
  preventHref: true,
  onClick: child.onClick || noop,
});

const patternflyItems = (data, currentLocation, currentOrganization) =>
  data.map(item => {
    const childrenArray = item.children
      .filter(child => child.name)
      .map(child =>
        childToMenuItem(child, currentLocation, currentOrganization)
      );

    return {
      title: item.name,
      iconClass: item.icon,
      subItems: childrenArray,
      className: item.className,
    };
  });
