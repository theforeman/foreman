import { createSelector } from 'reselect';
import { get } from 'lodash';

export const selectLayout = state => state.layout;

export const selectMenuItems = state => selectLayout(state).items;
export const selectActiveMenu = state => selectLayout(state).activeMenu;
export const selectIsLoading = state => selectLayout(state).isLoading;
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
        title: child.name,
        isDivider: child.type === 'divider' && !!child.name,
        className:
          child.name === currentLocation || child.name === currentOrganization
            ? 'mobile-active'
            : '',
        href: child.url ? child.url : '#',
        preventHref: false,
        onClick: child.onClick ? () => child.onClick() : null,
      };
      childrenArray.push(childObject);
    });
    const itemObject = {
      title: item.name,
      initialActive: item.active,
      iconClass: item.icon,
      subItems: childrenArray,
      className: item.className,
    };
    items.push(itemObject);
  });
  return items;
};
