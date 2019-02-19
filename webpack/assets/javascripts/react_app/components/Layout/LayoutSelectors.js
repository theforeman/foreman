import { createSelector } from 'reselect';
import { get } from 'lodash';
import { noop } from '../../common/helpers';
import { pages } from '../../routes';

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
      const isReact =
        pages.filter(route => route.path === child.url).length > 0;

      const childObject = {
        url: child.url,
        title: child.name,
        isDivider: child.type === 'divider' && !!child.name,
        className:
          child.name === currentLocation || child.name === currentOrganization
            ? 'mobile-active'
            : '',
        href: child.url || '#',
        preventHref: !!isReact,
        onClick: isReact ? noop : child.onClick,
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
