import React from 'react';

import {
  Page,
  PageSidebar,
  Flex,
  FlexItem,
  PageSidebarBody,
} from '@patternfly/react-core';
import { layoutPropTypes, layoutDefaultProps } from './LayoutHelper';
import { InstanceBanner } from './components/InstanceBanner';
import Header from './components/Toolbar/Header';
import Navigation from './Navigation';
import './layout.scss';

const Layout = ({
  items,
  data,
  isLoading,
  navigate,
  children,
  navigationActiveItem,
  setNavigationActiveItem,
}) => (
  <Flex
    direction={{ default: 'column' }}
    flexWrap={{ default: 'nowrap' }}
    spaceItems={{ default: 'spaceItemsNone' }}
    style={{ height: '100%' }}
  >
    <FlexItem>
      <InstanceBanner data={data} />
    </FlexItem>
    <FlexItem grow={{ default: 'grow' }} style={{ minHeight: 0 }}>
      <Page
        isManagedSidebar
        mainContainerId="foreman-main-container"
        masthead={<Header data={data} isLoading={isLoading} />}
        id="foreman-page"
        sidebar={
          <PageSidebar>
            <PageSidebarBody>
              <Navigation
                items={items}
                navigate={navigate}
                navigationActiveItem={navigationActiveItem}
                setNavigationActiveItem={setNavigationActiveItem}
              />
            </PageSidebarBody>
          </PageSidebar>
        }
      >
        {children}
      </Page>
    </FlexItem>
  </Flex>
);

Layout.propTypes = layoutPropTypes;
Layout.defaultProps = layoutDefaultProps;

export default Layout;
