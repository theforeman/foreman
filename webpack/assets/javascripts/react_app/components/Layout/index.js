import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';

import { initializeLayout } from './LayoutActions';
import reducer from './LayoutReducer';
import {
  patternflyMenuItemsSelector,
  selectIsLoading,
} from './LayoutSelectors';
import { combineMenuItems } from './LayoutHelper';
import {
  useForemanOrganization,
  useForemanLocation,
  useForemanSettings,
} from '../../Root/Context/ForemanContext';

import Layout from './Layout';

const ConnectedLayout = ({ children, data }) => {
  const dispatch = useDispatch();
  const { displayNewHostsPage } = useForemanSettings();

  const currentLocation = useForemanLocation()?.title;
  const currentOrganization = useForemanOrganization()?.title;
  useEffect(() => {
    dispatch(
      initializeLayout({
        items: combineMenuItems(data, displayNewHostsPage),
        organization: data.orgs.current_org,
        location: data.locations.current_location,
      })
    );
  }, [data, dispatch, displayNewHostsPage]);

  const { push: navigate } = useHistory();
  const items = useSelector(state =>
    patternflyMenuItemsSelector(state, currentLocation, currentOrganization)
  );
  const isLoading = useSelector(state => selectIsLoading(state));

  const [navigationActiveItem, setNavigationActiveItem] = useState(null);

  return (
    <Layout
      data={data}
      navigate={navigate}
      items={items}
      isLoading={isLoading}
      navigationActiveItem={navigationActiveItem}
      setNavigationActiveItem={setNavigationActiveItem}
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
