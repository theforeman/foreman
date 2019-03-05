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

const patternflyItems = (data, currentLocation, currentOrganization) => {
  if (data.length === 0) return [];
  const items = [];

  data.forEach(item => {
    const childrenArray = [];
    item.children.forEach(child => {
      const childObject = {
        id: `menu_item_${snakeCase(child.name)}`,
        title: child.name,
        isDivider: child.type === 'divider' && !!child.name,
        className:
          child.name === currentLocation || child.name === currentOrganization
            ? 'mobile-active'
            : '',
        href: child.url || '#',
        preventHref: true,
        onClick: child.onClick || noop,
      };
      childrenArray.push(childObject);
    });
    const itemObject = {
      title: item.name,
      iconClass: item.icon,
      subItems: childrenArray,
      className: item.className,
    };
    items.push(itemObject);
  });
  return items;
};
