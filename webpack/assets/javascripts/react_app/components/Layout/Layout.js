import React from 'react';

import { Page, PageSidebar } from '@patternfly/react-core';
import { layoutPropTypes, layoutDefaultProps } from './LayoutHelper';
import Header from './components/Toolbar/Header';
import Navigation from './Navigation';
import './layout.scss';

const Layout = ({
  items,
  data,
  isLoading,
  isCollapsed,
  navigate,
  expandLayoutMenus,
  collapseLayoutMenus,
  children,
  navigationActiveItem,
  setNavigationActiveItem,
}) => {
  const onNavToggle = () => {
    if (isCollapsed) {
      expandLayoutMenus();
      document.body.classList.remove('collapsed-nav');
    } else {
      collapseLayoutMenus();
      document.body.classList.add('collapsed-nav');
    }
  };
  return (
    <>
      <Page
        mainContainerId="foreman-main-container"
        header={
          <Header data={data} onNavToggle={onNavToggle} isLoading={isLoading} />
        }
        id="foreman-page"
        sidebar={
          <PageSidebar
            isNavOpen={!isCollapsed}
            nav={
              <Navigation
                items={items}
                navigate={navigate}
                navigationActiveItem={navigationActiveItem}
                setNavigationActiveItem={setNavigationActiveItem}
              />
            }
          />
        }
      >
        {children}
      </Page>
    </>
  );
};

Layout.propTypes = layoutPropTypes;
Layout.defaultProps = layoutDefaultProps;

export default Layout;
