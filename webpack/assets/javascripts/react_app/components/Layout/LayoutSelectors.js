import { createSelector } from 'reselect';
import { isEmpty, get } from 'lodash';
import { changeActive } from '../../../foreman_navigation';
import { getCurrentPath } from './LayoutHelper';

export const selectLayout = state => state.layout;

export const selectMenuItems = state => selectLayout(state).items;
export const selectActiveMenu = state => selectLayout(state).activeMenu;
export const selectCurrentLocation = state => get(selectLayout(state), 'currentLocation.title');
export const selectCurrentOrganization = state => get(selectLayout(state), 'currentOrganization.title');
const path = getCurrentPath();

export const patternflyMenuItemsSelector = createSelector(
  selectMenuItems,
  selectActiveMenu,
  selectCurrentLocation,
  selectCurrentOrganization,
  (items, activeMenu, currentLocation, currentOrganization) =>
    patternflyItems(items, path, activeMenu, currentLocation, currentOrganization),
);

const patternflyItems = (data, activePath, activeMenu, currentLocation, currentOrganization) => {
  const items = [];
  if (isEmpty(data)) return [];

  data.forEach((item) => {
    let activeFlag = false;
    const childrenArray = [];
    item.children.forEach((child) => {
      if (isEmpty(activeMenu) && child.url === activePath) { // activeMenu after Full page reload
        activeFlag = true;
        changeActive(item.name);
      }

      const childObject = {
        title: child.name,
        isDivider: child.type === 'divider' && !isEmpty(child.name),
        className: (child.name === currentLocation || child.name === currentOrganization) ? 'mobile-active' : '',
        href: child.url ? child.url : '#',
        preventHref: false,
        onClick: child.onClick ? () => child.onClick() : null,
      };
      childrenArray.push(childObject);
    });
    const itemObject = {
      title: item.name,
      initialActive: activeFlag || item.active,
      iconClass: item.icon,
      subItems: childrenArray,
      className: item.className,
    };
    items.push(itemObject);
  });
  return items;
};
