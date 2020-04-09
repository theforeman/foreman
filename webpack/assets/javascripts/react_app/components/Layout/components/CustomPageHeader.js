/**
 * Modified PF4 PageHeader
 * Includes context selector area
 */
import React from 'react';
/* eslint-disable */
import styles from '@patternfly/react-styles/css/components/Page/page';
import { css } from '@patternfly/react-styles';
import BarsIcon from '@patternfly/react-icons/dist/js/icons/bars-icon';
/* eslint-enable */
import {
  Button,
  ButtonVariant,
  PageContextConsumer,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';

const CustomPageHeader = ({
  className,
  logo,
  logoProps,
  logoComponent,
  toolbar,
  avatar,
  topNav,
  isNavOpen,
  role,
  showNavToggle,
  onNavToggle,
  afterNavToggle,
  'aria-label': ariaLabel,
  contextSelector,
  ...props
}) => {
  const LogoComponent = logoComponent;
  return (
    <PageContextConsumer>
      {({
        isManagedSidebar,
        onNavToggle: managedOnNavToggle,
        isNavOpen: managedIsNavOpen,
      }) => {
        const navToggle = isManagedSidebar ? managedOnNavToggle : onNavToggle;
        const navOpen = isManagedSidebar ? managedIsNavOpen : isNavOpen;

        const navToggleFunctions = () => {
          navToggle();
          afterNavToggle(!navOpen);
        };

        return (
          <header
            role={role}
            className={css(styles.pageHeader, className)}
            {...props}
          >
            {(showNavToggle || logo) && (
              <div className={css(styles.pageHeaderBrand)}>
                {showNavToggle && (
                  <div className={css(styles.pageHeaderBrandToggle)}>
                    <Button
                      id="nav-toggle"
                      onClick={navToggleFunctions}
                      aria-label={ariaLabel}
                      aria-controls="page-sidebar"
                      aria-expanded={navOpen ? 'true' : 'false'}
                      variant={ButtonVariant.plain}
                    >
                      <BarsIcon />
                    </Button>
                  </div>
                )}
                {logo && (
                  <LogoComponent
                    className={css(styles.pageHeaderBrandLink)}
                    {...logoProps}
                  >
                    {logo}
                  </LogoComponent>
                )}
              </div>
            )}
            {contextSelector}
            {topNav && (
              <div className={css(styles.pageHeaderNav)}>{topNav}</div>
            )}
            {(toolbar || avatar) && (
              <div className={css(styles.pageHeaderTools)}>
                {toolbar}
                {avatar}
              </div>
            )}
          </header>
        );
      }}
    </PageContextConsumer>
  );
};
CustomPageHeader.propTypes = {
  /** Additional classes added to the page header */
  className: PropTypes.string,
  /** Component to render the logo/brand (e.g. <Brand />) */
  logo: PropTypes.node,
  /** Additional props passed to the logo anchor container */
  logoProps: PropTypes.any,
  /** Component to use to wrap the passed <logo> */
  logoComponent: PropTypes.node,
  /** Component to render the toolbar (e.g. <Toolbar />) */
  toolbar: PropTypes.node,
  /** Component to render the avatar (e.g. <Avatar /> */
  avatar: PropTypes.node,
  /** Component to render navigation within the header (e.g. <Nav /> */
  topNav: PropTypes.node,
  /** True to show the nav toggle button (toggles side nav) */
  showNavToggle: PropTypes.bool,
  /** True if the side nav is shown  */
  isNavOpen: PropTypes.bool,
  /** Sets the value for role on the <main> element */
  role: PropTypes.string,
  /** Callback function to handle the side nav toggle button, managed by the Page component if the Page isManagedSidebar prop is set to true */
  onNavToggle: PropTypes.func,
  /** Aria Label for the nav toggle button */
  'aria-label': PropTypes.string,
  /** Callback function after nav is toggled */
  afterNavToggle: PropTypes.func,
  /** Context selector area */
  contextSelector: PropTypes.node,
};
CustomPageHeader.defaultProps = {
  className: '',
  logo: null,
  logoProps: null,
  logoComponent: 'a',
  toolbar: null,
  avatar: null,
  topNav: null,
  isNavOpen: true,
  role: undefined,
  showNavToggle: false,
  onNavToggle: () => undefined,
  afterNavToggle: () => undefined,
  'aria-label': 'Global navigation',
  contextSelector: null,
};
export default CustomPageHeader;
