/* eslint-disable no-unused-vars */
// eslint bug - https://github.com/eslint/eslint/issues/12117

import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import {
  changeOrganization,
  changeLocation,
} from '../../../foreman_navigation';
import { translate as __ } from '../../common/I18n';
import { ANY_ORGANIZATION_TEXT, ANY_LOCATION_TEXT } from './LayoutConstants';
import { removeLastSlashFromPath, noop } from '../../common/helpers';

export const createInitialTaxonomy = (currentTaxonomy, availableTaxonomies) => {
  const taxonomyId = availableTaxonomies.find(
    taxonomy => taxonomy.title === currentTaxonomy
  ).id;

  return {
    title: currentTaxonomy,
    id: taxonomyId,
  };
};

export const getCurrentPath = () =>
  removeLastSlashFromPath(window.location.pathname);

export const getActiveMenuItem = (items, path = getCurrentPath()) => {
  for (const item of items) {
    for (const child of item.children) {
      if (child.exact) {
        if (path === child.url) return { title: item.name };
      } else if (path.startsWith(child.url)) return { title: item.name };
    }
  }
  return { title: '' };
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
    name: ANY_ORGANIZATION_TEXT,
    url: '/organizations/clear',
    onClick: () => {
      changeOrganization(ANY_ORGANIZATION_TEXT);
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
  };
  return orgItem;
};

const createLocationItem = locations => {
  const anyLoc = {
    name: ANY_LOCATION_TEXT,
    url: '/locations/clear',
    onClick: () => {
      changeLocation(ANY_LOCATION_TEXT);
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
  };
  return locItem;
};

export const organizationPropType = PropTypes.shape({
  current_org: PropTypes.string,
  available_organizations: PropTypes.arrayOf(
    PropTypes.shape({
      href: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
    })
  ),
});

export const locationPropType = PropTypes.shape({
  current_location: PropTypes.string,
  available_locations: PropTypes.arrayOf(
    PropTypes.shape({
      href: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
    })
  ),
});

export const userPropType = PropTypes.shape({
  current_user: PropTypes.object.isRequired,
  user_dropdown: PropTypes.arrayOf(
    PropTypes.shape({
      children: PropTypes.any,
      icon: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ),
});

export const layoutPropTypes = {
  children: PropTypes.node,
  currentOrganization: PropTypes.string,
  currentLocation: PropTypes.string,
  isLoading: PropTypes.bool,
  isCollapsed: PropTypes.bool,
  activeMenu: PropTypes.string,
  navigate: PropTypes.func,
  changeActiveMenu: PropTypes.func,
  changeOrganization: PropTypes.func,
  changeLocation: PropTypes.func,
  expandLayoutMenus: PropTypes.func,
  collapseLayoutMenus: PropTypes.func,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string.isRequired,
      className: PropTypes.string,
      iconClass: PropTypes.string.isRequired,
      initialActive: PropTypes.bool,
      subItems: PropTypes.arrayOf(
        PropTypes.shape({
          title: PropTypes.string,
          isDivider: PropTypes.bool,
          className: PropTypes.string,
          href: PropTypes.string,
        })
      ),
    })
  ),
  data: PropTypes.shape({
    brand: PropTypes.string,
    stop_impersonation_url: PropTypes.string.isRequired,
    instance_title: PropTypes.string,
    menu: PropTypes.arrayOf(
      PropTypes.shape({
        type: PropTypes.string.isRequired,
        name: PropTypes.string.isRequired,
        icon: PropTypes.string.isRequired,
        children: PropTypes.any,
      })
    ),
    locations: locationPropType,
    orgs: organizationPropType,
    root: PropTypes.string.isRequired,
    logo: PropTypes.string.isRequired,
    notification_url: PropTypes.string.isRequired,
    taxonomies: PropTypes.shape({
      locations: PropTypes.bool.isRequired,
      organizations: PropTypes.bool.isRequired,
    }),
    user: userPropType,
  }),
};

export const layoutDefaultProps = {
  children: null,
  items: [],
  data: {},
  currentOrganization: ANY_ORGANIZATION_TEXT,
  currentLocation: ANY_LOCATION_TEXT,
  isLoading: false,
  isCollapsed: false,
  activeMenu: '',
  navigate: noop,
  changeActiveMenu: noop,
  changeOrganization: noop,
  changeLocation: noop,
  expandLayoutMenus: noop,
  collapseLayoutMenus: noop,
};
