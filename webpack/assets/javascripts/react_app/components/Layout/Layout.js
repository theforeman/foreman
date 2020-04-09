import React from 'react';
import {
  Brand,
  Page,
  PageSection,
  PageSectionVariants,
  PageSidebar,
  SkipToContent,
} from '@patternfly/react-core';
// eslint-disable-next-line
import globalBreakpointMd from '@patternfly/react-tokens/dist/js/global_breakpoint_md';
import CustomPageHeader from './components/CustomPageHeader';
import {
  getActive,
  getCurrentPath,
  layoutPropTypes,
  layoutDefaultProps,
} from './LayoutHelper';
import VerticalNav from './components/VerticalNav';
import Toolbar from './components/Toolbar';
import './layout.scss';

class Layout extends React.Component {
  componentDidMount() {
    const {
      items,
      data,
      fetchMenuItems,
      changeLocation,
      currentLocation,
      changeOrganization,
      currentOrganization,
      changeActiveMenu,
      activeMenu,
    } = this.props;
    if (items.length === 0) fetchMenuItems(data);

    const activeURLMenu = getActive(data.menu, getCurrentPath());
    if (activeMenu !== activeURLMenu.title) {
      changeActiveMenu(activeURLMenu);
    }

    if (
      data.taxonomies.locations &&
      !!data.locations.current_location &&
      currentLocation !== data.locations.current_location
    ) {
      const initialLocTitle = data.locations.current_location;
      const initialLocId = data.locations.available_locations.find(
        loc => loc.title === initialLocTitle
      ).id;
      changeLocation({ title: initialLocTitle, id: initialLocId });
    }

    if (
      data.taxonomies.organizations &&
      !!data.orgs.current_org &&
      currentOrganization !== data.orgs.current_org
    ) {
      const initialOrgTitle = data.orgs.current_org;
      const initialOrgId = data.orgs.available_organizations.find(
        org => org.title === initialOrgTitle
      ).id;
      changeOrganization({ title: initialOrgTitle, id: initialOrgId });
    }
  }

  render() {
    const {
      items,
      data,
      isLoading,
      changeActiveMenu,
      changeOrganization,
      changeLocation,
      currentOrganization,
      currentLocation,
      activeMenu,
      children,
      history,
    } = this.props;

    const afterNavToggle = navOpen => {
      const mobileView =
        window.innerWidth < Number.parseInt(globalBreakpointMd.value, 10);
      if (mobileView) {
        // ignore for mobile view
        return;
      }
      // toggles a class in the body tag, so that the main #rails-app-content container can have the appropriate width
      if (navOpen) {
        document.body.classList.add('pf-m-expanded');
      } else {
        document.body.classList.remove('pf-m-expanded');
      }
    };
    const header = (
      <CustomPageHeader
        logo={
          <Brand
            src={data.logo}
            alt={data.brand}
            style={{ marginTop: '8px' }}
          />
        }
        logoProps={{ href: data.root }}
        showNavToggle
        contextSelector={
          <Toolbar
            data={data}
            currentLocation={currentLocation}
            changeLocation={changeLocation}
            currentOrganization={currentOrganization}
            changeOrganization={changeOrganization}
            isLoading={isLoading}
            changeActiveMenu={changeActiveMenu}
          />
        }
        afterNavToggle={afterNavToggle}
        className="navbar-pf-vertical"
      />
    );
    const sidebar = (
      <PageSidebar
        nav={
          <VerticalNav
            items={items}
            activeMenu={activeMenu}
            changeActiveMenu={changeActiveMenu}
            history={history}
          />
        }
        theme="dark"
      />
    );
    const pageId = 'main';
    const pageSkipToContent = (
      <SkipToContent href={`#${pageId}`}>Skip to content</SkipToContent>
    );

    return (
      <Page
        header={header}
        sidebar={sidebar}
        isManagedSidebar
        skipToContent={pageSkipToContent}
        mainContainerId={pageId}
        className="foreman-theme"
      >
        <PageSection variant={PageSectionVariants.light}>
          {children}
        </PageSection>
      </Page>
    );
  }
}

Layout.propTypes = {
  ...layoutPropTypes,
};

Layout.defaultProps = {
  ...layoutDefaultProps,
};

export default Layout;
