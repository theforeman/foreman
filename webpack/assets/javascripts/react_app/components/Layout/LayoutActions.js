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

export const changeOrg = (id, org) => (dispatch) => {
  // use ID for api
  dispatch({
    type: LAYOUT_CHANGE_ORG,
    payload: {
      org,
    },
  });
};

export const changeLoc = (id, location) => (dispatch) => {
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
          onClick: () => window.Turbolinks.visit(child.url),
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

  // Organizations

  if (data.taxonomies.organizations) {
    let activeFlag = false;
    const anyOrg = {
      title: 'Any Organization',
      onClick: () => window.Turbolinks.visit('/organizations/clear'),
    };

    const childrenArray = [];
    childrenArray.push(anyOrg);

    data.organizations.forEach((child) => {
      if (child.href === activePath) activeFlag = true;
      const childObject = {
        title: isEmpty(child.title) === true ? child.title : __(child.title),
        onClick: () => {
          changeOrg(child.id, child.title);
          window.Turbolinks.visit(child.href);
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
    items.push(orgItem);
  }

  // Locations

  if (data.taxonomies.locations) {
    let activeFlag = false;
    const anyLoc = {
      title: 'Any Location',
      onClick: () => window.Turbolinks.visit('/locations/clear'),
    };

    const childrenArray = [];
    childrenArray.push(anyLoc);

    data.locations.forEach((child) => {
      if (child.href === activePath) activeFlag = true;
      const childObject = {
        title: isEmpty(child.title) === true ? child.title : __(child.title),
        onClick: () => {
          changeOrg(child.id, child.title);
          window.Turbolinks.visit(child.href);
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
    items.push(locItem);
  }

  // User

  if (!isEmpty(data.user_dropdown)) {
    let activeFlag = false;
    const userSubItems = [];
    data.user_dropdown[0].children.forEach((child) => {
      if (child.url === activePath) activeFlag = true;
      const childObject = {
        title: child.name,
        onClick: () => window.Turbolinks.visit(child.url),
      };
      userSubItems.push(childObject);
    });

    const userItem = {
      title: __(data.user_dropdown[0].name),
      iconClass: data.user_dropdown[0].icon,
      initialActive: activeFlag,
      subItems: userSubItems,
      className: 'visible-xs-block',
    };
    items.push(userItem);
  }
  return items;
};
const isEmpty = str => !str || str.length === 0;
