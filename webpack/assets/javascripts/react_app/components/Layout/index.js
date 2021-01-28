import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';

import {
  initializeLayout,
  changeActiveMenu,
  changeOrganization,
  changeLocation,
  collapseLayoutMenus,
  expandLayoutMenus,
} from './LayoutActions';
import reducer from './LayoutReducer';
import {
  patternflyMenuItemsSelector,
  selectActiveMenu,
  selectCurrentOrganization,
  selectCurrentLocation,
  selectIsLoading,
  selectIsCollapsed,
} from './LayoutSelectors';
import {
  createInitialTaxonomy,
  combineMenuItems,
  getActiveMenuItem,
} from './LayoutHelper';
import { getIsNavbarCollapsed } from './LayoutSessionStorage';

import Layout from './Layout';

const ConnectedLayout = ({ children, data }) => {
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(
      initializeLayout({
        items: combineMenuItems(data),
        activeMenu: getActiveMenuItem(data.menu).title,
        isCollapsed: getIsNavbarCollapsed(),
        organization:
          data.orgs.current_org &&
          createInitialTaxonomy(
            data.orgs.current_org,
            data.orgs.available_organizations
          ),
        location:
          data.locations.current_location &&
          createInitialTaxonomy(
            data.locations.current_location,
            data.locations.available_locations
          ),
      })
    );
  }, [data, dispatch]);

  const { push: navigate } = useHistory();
  const items = useSelector(state => patternflyMenuItemsSelector(state));
  const isLoading = useSelector(state => selectIsLoading(state));
  const isCollapsed = useSelector(state => selectIsCollapsed(state));
  const activeMenu = useSelector(state => selectActiveMenu(state));
  const currentOrganization = useSelector(state =>
    selectCurrentOrganization(state)
  );
  const currentLocation = useSelector(state => selectCurrentLocation(state));

  return (
    <Layout
      data={data}
      navigate={navigate}
      items={items}
      isLoading={isLoading}
      isCollapsed={isCollapsed}
      activeMenu={activeMenu}
      currentOrganization={currentOrganization}
      currentLocation={currentLocation}
      changeActiveMenu={menu => dispatch(changeActiveMenu(menu))}
      changeOrganization={org => dispatch(changeOrganization(org))}
      changeLocation={loc => dispatch(changeLocation(loc))}
      collapseLayoutMenus={() => dispatch(collapseLayoutMenus())}
      expandLayoutMenus={() => dispatch(expandLayoutMenus())}
    >
      {children}
    </Layout>
  );
};

// export prop-types
export const { propTypes, defaultProps } = Layout;

ConnectedLayout.propTypes = {
  children: propTypes.children,
  data: propTypes.data,
};

ConnectedLayout.defaultProps = {
  children: defaultProps.children,
  data: defaultProps.data,
};

// export reducers
export const reducers = { layout: reducer };

// export connected component
export default ConnectedLayout;
