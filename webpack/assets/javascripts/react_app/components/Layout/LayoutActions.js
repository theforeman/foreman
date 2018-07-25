import { isEmpty } from 'lodash';
import { navigateTo } from '../../../foreman_navigation';

import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_RESOURCES_REQUEST,
  LAYOUT_CHANGE_LOCATION,
  LAYOUT_CHANGE_ORG,
} from './LayoutConstants';

export const showLoading = () => ({
  type: LAYOUT_SHOW_LOADING,
});

export const hideLoading = () => ({
  type: LAYOUT_HIDE_LOADING,
});

export const changeActiveMenu = primary => (dispatch) => {
  dispatch({
    type: LAYOUT_CHANGE_ACTIVE,
    payload: {
      primary,
    },
  });
};

export const fetchMenuItems = menuItems => (dispatch) => {
  const activePath = window.location.pathname;
  const items = customItems(menuItems, activePath);

  dispatch({
    type: LAYOUT_RESOURCES_REQUEST,
    payload: {
      items,
    },
  });
};

export const changeOrganization = org => (dispatch) => {
  dispatch({
    type: LAYOUT_CHANGE_ORG,
    payload: {
      org,
    },
  });
};

export const changeLocation = location => (dispatch) => {
  // use ID for api
  dispatch({
    type: LAYOUT_CHANGE_LOCATION,
    payload: {
      location,
    },
  });
};

const customItems = (data, activePath) => {
  const items = [];

  // Menu Items

  data.menu.forEach((menu) => {
    menu.forEach((item) => {
      let activeFlag = false;
      const childrenArray = [];
      item.children.forEach((child) => {
        if (child.url === activePath) activeFlag = true;

        const childObject = {
          title: isEmpty(child.name) === true ? child.name : __(child.name),
          isDivider: child.type === 'divider' && !isEmpty(child.name),
          onClick: () => navigateTo(child.url),
        };
        childrenArray.push(childObject);
      });
      const itemObject = {
        title: __(item.name),
        initialActive: activeFlag,
        iconClass: item.icon,
        subItems: childrenArray,
      };
      items.push(itemObject);
    });
  });
  if (data.taxonomies.organizations) {
    items.push(fetchOrganizations(data.organizations, activePath));
  }

  if (data.taxonomies.locations) {
    items.push(fetchLocations(data.locations, activePath));
  }

  if (!isEmpty(data.user_dropdown)) {
    items.push(fetchUser(data.user_dropdown[0], activePath));
  }
  return items;
};

const fetchOrganizations = (orgs, activePath) => {
  let activeFlag = false;
  const anyOrg = {
    title: __('Any Organization'),
    onClick: () => {
      navigateTo('/organizations/clear');
      changeOrganization('Any Organization');
    },
  };

  const childrenArray = [];
  childrenArray.push(anyOrg);

  orgs.forEach((child) => {
    if (child.href === activePath) activeFlag = true;
    const childObject = {
      title: isEmpty(child.title) === true ? child.title : __(child.title),
      onClick: () => {
        changeOrganization(child.title);
        navigateTo(child.href);
      },
    };
    childrenArray.push(childObject);
  });

  const orgItem = {
    title: __('Organizations'),
    initialActive: activeFlag,
    iconClass: 'fa fa-building',
    subItems: childrenArray,
    className: 'visible-xs-block',
  };
  return orgItem;
};

const fetchLocations = (locations, activePath) => {
  let activeFlag = false;
  const anyLoc = {
    title: __('Any Location'),
    onClick: () => {
      changeLocation('Any Location');
      navigateTo('/locations/clear');
    },
  };

  const childrenArray = [];
  childrenArray.push(anyLoc);

  locations.forEach((child) => {
    if (child.href === activePath) activeFlag = true;
    const childObject = {
      title: isEmpty(child.title) === true ? child.title : __(child.title),
      onClick: () => {
        changeLocation(child.title);
        navigateTo(child.href);
      },
    };
    childrenArray.push(childObject);
  });

  const locItem = {
    title: __('Locations'),
    initialActive: activeFlag,
    iconClass: 'fa fa-globe',
    subItems: childrenArray,
    className: 'visible-xs-block',
  };
  return locItem;
};

const fetchUser = (user, activePath) => {
  let activeFlag = false;
  const userSubItems = [];
  user.children.forEach((child) => {
    if (child.url === activePath) activeFlag = true;
    const childObject = {
      title: child.name,
      onClick: () => navigateTo(child.url),
    };
    userSubItems.push(childObject);
  });

  const userItem = {
    title: user.name,
    iconClass: user.icon,
    initialActive: activeFlag,
    subItems: userSubItems,
    className: 'visible-xs-block',
  };
  return userItem;
};
