import { snakeCase } from 'lodash';
import { noop } from '../../common/helpers';

export const selectLayout = state => state.layout;

export const selectMenuItems = state => selectLayout(state).items;
export const selectActiveMenu = state => selectLayout(state).activeMenu;
export const selectIsLoading = state => selectLayout(state).isLoading;
export const selectIsCollapsed = state => selectLayout(state).isCollapsed;

export const patternflyMenuItemsSelector = (
  state,
  currentLocation,
  currentOrganization
) => {
  const items = selectMenuItems(state);
  return items.map(item => {
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
};

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
