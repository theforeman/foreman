import { isEmpty } from 'lodash';
import {
  changeOrganization,
  changeLocation,
} from '../../../foreman_navigation';
import { translate as __ } from '../../common/I18n';

export const getCurrentPath = () => window.location.pathname;

export const getActive = (data, path) => {
  let activeItem = '';
  data.forEach(item => {
    item.children.forEach(child => {
      if (child.url === path) activeItem = item.name;
    });
  });
  return { title: activeItem };
};

export const handleMenuClick = (primary, activeMenu, changeActive) => {
  if (primary.title !== activeMenu) changeActive(primary);
};

export const combineMenuItems = data => {
  const items = [];

  data.menu.forEach(item => {
    const translatedChildren = item.children.map(child => ({
      ...child,
      name: isEmpty(child.name) ? child.name : __(child.name),
    }));

    const translatedItem = {
      ...item,
      name: __(item.name),
      children: translatedChildren,
      // Hiding user if not on Mobile view
      className: item.name === 'User' ? 'visible-xs-block' : '',
    };
    items.push(translatedItem);
  });

  if (data.taxonomies.organizations) {
    items.push(createOrgItem(data.orgs.available_organizations));
  }

  if (data.taxonomies.locations) {
    items.push(createLocationItem(data.locations.available_locations));
  }
  return items;
};

const createOrgItem = orgs => {
  const anyOrg = {
    name: __('Any Organization'),
    url: '/organizations/clear',
    onClick: () => {
      changeOrganization(__('Any Organization'));
    },
  };
  const childrenArray = [];
  childrenArray.push(anyOrg);

  orgs.forEach(org => {
    const childObject = {
      type: org.type,
      name: isEmpty(org.title) ? org.title : __(org.title),
      onClick: () => {
        changeOrganization(__(org.title));
      },
      url: org.href,
    };
    childrenArray.push(childObject);
  });

  const orgItem = {
    type: 'sub_menu',
    name: __('Organizations'),
    icon: 'fa fa-building',
    children: childrenArray,
    // Hiding Organizations if not on Mobile view
    className: 'visible-xs-block',
    active: false,
  };
  return orgItem;
};

const createLocationItem = locations => {
  const anyLoc = {
    name: __('Any Location'),
    url: '/locations/clear',
    onClick: () => {
      changeLocation(__('Any Location'));
    },
  };
  const childrenArray = [];
  childrenArray.push(anyLoc);

  locations.forEach(loc => {
    const childObject = {
      type: loc.type,
      name: isEmpty(loc.title) ? loc.title : __(loc.title),
      onClick: () => {
        changeLocation(__(loc.title));
      },
      url: loc.href,
    };
    childrenArray.push(childObject);
  });

  const locItem = {
    type: 'sub_menu',
    name: __('Locations'),
    icon: 'fa fa-globe',
    children: childrenArray,
    // Hiding Locations if not on Mobile view
    className: 'visible-xs-block',
    active: false,
  };
  return locItem;
};
