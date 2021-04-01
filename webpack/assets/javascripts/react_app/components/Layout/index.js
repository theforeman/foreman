import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';

import {
  initializeLayout,
  collapseLayoutMenus,
  expandLayoutMenus,
  changeIsNavOpen,
} from './LayoutActions';
import reducer from './LayoutReducer';
import {
  patternflyMenuItemsSelector,
  selectIsLoading,
  selectIsNavOpen,
} from './LayoutSelectors';
import { combineMenuItems } from './LayoutHelper';

import { getIsNavbarOpen } from './LayoutSessionStorage';

import Layout from './Layout';

const ConnectedLayout = ({ children, data }) => {
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(
      initializeLayout({
        items: combineMenuItems(data),
        isNavOpen: getIsNavbarOpen(),
        organization: data.orgs.current_org,
        location: data.locations.current_location,
      })
    );
  }, [data, dispatch]);

  const isNavOpen = useSelector(state => selectIsNavOpen(state));
  useEffect(() => {
    // toggles a class in the body tag, so that the main #rails-app-content container can have the appropriate width
    if (isNavOpen) {
      document.body.classList.add('pf-m-expanded');
    } else {
      document.body.classList.remove('pf-m-expanded');
    }
  }, [isNavOpen]);

  const { push: navigate } = useHistory();
  const items = useSelector(state => patternflyMenuItemsSelector(state));
  const isLoading = useSelector(state => selectIsLoading(state));
  return (
    <Layout
      data={data}
      navigate={navigate}
      items={items}
      isLoading={isLoading}
      isNavOpen={isNavOpen}
      collapseLayoutMenus={() => dispatch(collapseLayoutMenus())}
      expandLayoutMenus={() => dispatch(expandLayoutMenus())}
      changeIsNavOpen={value => dispatch(changeIsNavOpen(value))}
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
