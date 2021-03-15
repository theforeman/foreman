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
  selectIsLoading,
  selectIsCollapsed,
} from './LayoutSelectors';
import { combineMenuItems, getActiveMenuItem } from './LayoutHelper';
import { getIsNavbarCollapsed } from './LayoutSessionStorage';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../Root/Context/ForemanContext';

import Layout from './Layout';

const ConnectedLayout = ({ children, data }) => {
  const dispatch = useDispatch();

  const currentLocation = useForemanLocation()?.title;
  const currentOrganization = useForemanOrganization()?.title;
  useEffect(() => {
    dispatch(
      initializeLayout({
        items: combineMenuItems(data),
        activeMenu: getActiveMenuItem(data.menu).title,
        isCollapsed: getIsNavbarCollapsed(),
        organization: data.orgs.current_org,
        location: data.locations.current_location,
      })
    );
  }, [data, dispatch]);

  const { push: navigate } = useHistory();
  const items = useSelector(state =>
    patternflyMenuItemsSelector(state, currentLocation, currentOrganization)
  );
  const isLoading = useSelector(state => selectIsLoading(state));
  const isCollapsed = useSelector(state => selectIsCollapsed(state));
  const activeMenu = useSelector(state => selectActiveMenu(state));

  return (
    <Layout
      data={data}
      navigate={navigate}
      items={items}
      isLoading={isLoading}
      isCollapsed={isCollapsed}
      activeMenu={activeMenu}
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
