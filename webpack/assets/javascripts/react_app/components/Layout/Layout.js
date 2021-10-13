import React from 'react';

import { VerticalNav } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';

import {
  handleMenuClick,
  layoutPropTypes,
  layoutDefaultProps,
} from './LayoutHelper';
import LayoutContainer from './components/LayoutContainer';
import HeaderToolbar from './components/Toolbar/HeaderToolbar';
import './layout.scss';

const Layout = ({
  items,
  data,
  isLoading,
  isCollapsed,
  navigate,
  expandLayoutMenus,
  collapseLayoutMenus,
  changeActiveMenu,
  activeMenu,
  children,
}) => (
  <React.Fragment>
    <VerticalNav
      hoverDelay={100}
      items={items}
      onItemClick={(primary) =>
        handleMenuClick(primary, activeMenu, changeActiveMenu)
      }
      onNavigate={({ href }) => navigate(href)}
      activePath={`/${__(activeMenu || 'active')}/`}
      onCollapse={collapseLayoutMenus}
      onExpand={expandLayoutMenus}
    >
      <VerticalNav.Masthead>
        <header className="pf-c-page__header pf-c-page" id="navbar-header">
          <VerticalNav.Brand
            title={data.brand}
            iconImg={data.logo}
            href={data.root}
          />
          <HeaderToolbar
            {...data}
            isLoading={isLoading}
            changeActiveMenu={changeActiveMenu}
          />
        </header>
      </VerticalNav.Masthead>
    </VerticalNav>
    <LayoutContainer isCollapsed={isCollapsed}>{children}</LayoutContainer>
  </React.Fragment>
);

Layout.propTypes = layoutPropTypes;
Layout.defaultProps = layoutDefaultProps;

export default Layout;
