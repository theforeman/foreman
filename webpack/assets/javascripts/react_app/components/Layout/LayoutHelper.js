/* eslint-disable no-unused-vars */
// eslint bug - https://github.com/eslint/eslint/issues/12117

import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';
import {
  removeLastSlashFromPath,
  noop,
  foremanUrl,
} from '../../common/helpers';

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
      className: item.name === 'User' ? 'hidden-nav-lg' : '',
    };
    items.push(translatedItem);
  });

  items.push(
    createOrgItem(data.orgs.available_organizations, data.orgs.current_org)
  );
  items.push(
    createLocationItem(
      data.locations.available_locations,
      data.locations.current_location
    )
  );

  return items;
};

const createOrgItem = (orgs, currentOrganization) => {
  const anyOrg = {
    name: __('Any Organization'),
    onClick: () => {
      window.location.assign(foremanUrl('/organizations/clear'));
    },
    isActive: !currentOrganization,
  };
  const childrenArray = [anyOrg];

  orgs.forEach(org => {
    const childObject = {
      type: org.type,
      name: org.title,
      onClick: () => {
        window.location.assign(org.href);
      },
      isActive: currentOrganization === org.title,
    };
    childrenArray.push(childObject);
  });

  const orgItem = {
    type: 'sub_menu',
    name: __('Organizations'),
    icon: 'fa fa-building',
    children: childrenArray,
    // Hiding Organizations if not on Mobile view
    className: 'organization-menu hidden-nav-lg',
  };
  return orgItem;
};

const createLocationItem = (locations, currentLocation) => {
  const anyLoc = {
    name: __('Any Location'),
    onClick: () => {
      window.location.assign(foremanUrl('/locations/clear'));
    },
    isActive: !currentLocation,
  };
  const childrenArray = [anyLoc];

  locations.forEach(loc => {
    const childObject = {
      type: loc.type,
      name: loc.title,
      onClick: () => {
        window.location.assign(loc.href);
      },
      isActive: currentLocation === loc.title,
    };
    childrenArray.push(childObject);
  });

  const locItem = {
    type: 'sub_menu',
    name: __('Locations'),
    icon: 'fa fa-globe',
    children: childrenArray,
    // Hiding Locations if not on Mobile view
    className: 'location-menu hidden-nav-lg',
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

export const dataPropType = {
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
  user: userPropType,
};

export const layoutPropTypes = {
  children: PropTypes.node,
  isLoading: PropTypes.bool,
  isNavOpen: PropTypes.bool,
  navigate: PropTypes.func,
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
  data: PropTypes.shape(dataPropType),
};

export const layoutDefaultProps = {
  children: null,
  items: [],
  data: {},
  isLoading: false,
  navigate: noop,
  expandLayoutMenus: noop,
  collapseLayoutMenus: noop,
};
