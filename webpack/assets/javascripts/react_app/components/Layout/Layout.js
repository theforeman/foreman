import React from 'react';
import {
  Brand,
  Page,
  PageSection,
  PageSectionVariants,
  PageSidebar,
  SkipToContent,
  PageHeader,
} from '@patternfly/react-core';

import { translate as __ } from '../../common/I18n';
import VerticalNav from './components/VerticalNav';
import HeaderToolbar from './components/Toolbar/HeaderToolbar';

import { layoutPropTypes, layoutDefaultProps } from './LayoutHelper';
import './layout.scss';

const Layout = ({
  items,
  data,
  isLoading,
  isNavOpen,
  navigate,
  children,
  changeIsNavOpen,
}) => {
  const onNavToggle = () => {
    isNavOpen ? changeIsNavOpen(false) : changeIsNavOpen(true);
  };
  const header = (
    <PageHeader
      logo={
        <React.Fragment>
          <Brand src={data.logo} alt={data.brand} href={data.root} />
          <span className="navbar-brand-txt">
            <span>{data.brand}</span>
          </span>
        </React.Fragment>
      }
      logoProps={{ href: data.root }}
      showNavToggle
      isManagedSidebar
      onNavToggle={onNavToggle}
      headerTools={<HeaderToolbar {...data} isLoading={isLoading} />}
    />
  );

  const sidebar = (
    <PageSidebar
      isNavOpen={isNavOpen}
      nav={<VerticalNav items={items} navigate={navigate} />}
    />
  );
  const pageId = 'main';
  const pageSkipToContent = (
    <SkipToContent href={`#${pageId}`}>{__('Skip to content')}</SkipToContent>
  );
  return (
    <Page
      header={header}
      sidebar={sidebar}
      skipToContent={pageSkipToContent}
      mainContainerId={pageId}
    >
      <PageSection
        className="react-container nav-pf-persistent-secondary"
        variant={PageSectionVariants.light}
      >
        {children}
      </PageSection>
    </Page>
  );
};
Layout.propTypes = layoutPropTypes;

Layout.defaultProps = layoutDefaultProps;

export default Layout;
