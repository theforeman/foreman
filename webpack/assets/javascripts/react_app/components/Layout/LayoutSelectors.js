import { get, snakeCase } from 'lodash';
import { noop } from '../../common/helpers';
import { deprecate } from '../../common/DeprecationService';

export const selectLayout = state => state.layout;

export const selectMenuItems = state => selectLayout(state).items;
export const selectIsLoading = state => selectLayout(state).isLoading;
export const selectIsNavOpen = state => selectLayout(state).isNavOpen;
export const selectCurrentLocation = state => {
  deprecate('selectCurrentLocation', 'useForemanLocation hook', 2.5);
  return get(selectLayout(state), 'currentLocation');
};
export const selectCurrentOrganization = state => {
  deprecate('selectCurrentOrganization', 'useForemanOrganization hook', 2.5);
  return get(selectLayout(state), 'currentOrganization');
};

export const patternflyMenuItemsSelector = state => {
  const items = selectMenuItems(state);
  return items.map(item => {
    const childrenArray = item.children
      .filter(child => child.name)
      .map(child => childToMenuItem(child));

    return {
      title: item.name,
      iconClass: item.icon,
      subItems: childrenArray,
      className: item.className,
    };
  });
};

const childToMenuItem = child => ({
  id: `menu_item_${snakeCase(child.name)}`,
  title: child.name,
  isDivider: child.type === 'divider',
  href: child.url || '#',
  preventHref: true,
  onClick: child.onClick || noop,
  isActive: child.isActive,
});
