import React from 'react';
import PropTypes from 'prop-types';
import {
  Brand,
  Masthead,
  MastheadToggle,
  MastheadMain,
  MastheadLogo,
  MastheadBrand,
  MastheadContent,
  PageToggleButton,
} from '@patternfly/react-core';
import { BarsIcon } from '@patternfly/react-icons';

import {
  layoutPropTypes,
  layoutDefaultProps,
  dataPropType,
} from '../../LayoutHelper';
import HeaderToolbar from './HeaderToolbar';
import { MASTHEAD_LOGO_HEIGHT } from '../../LayoutConstants';

const Header = ({ data: { logo, brand, root, ...props }, isLoading }) => (
  <Masthead display={{ default: 'inline' }}>
    <MastheadMain>
      <MastheadToggle>
        <PageToggleButton icon={<BarsIcon />} ouiaId="nav-toggle" />
      </MastheadToggle>
      <MastheadBrand>
        <MastheadLogo component="a" href={root}>
          <React.Fragment>
            <Brand
              src={logo}
              alt={brand}
              href={root}
              heights={{ default: MASTHEAD_LOGO_HEIGHT }}
            />
            <span className="navbar-brand-txt">
              <span>{brand}</span>
            </span>
          </React.Fragment>
        </MastheadLogo>
      </MastheadBrand>
    </MastheadMain>
    <MastheadContent>
      <HeaderToolbar {...props} isLoading={isLoading} />
    </MastheadContent>
  </Masthead>
);

Header.propTypes = {
  data: PropTypes.shape(dataPropType).isRequired,
  isLoading: layoutPropTypes.isLoading,
};

Header.defaultProps = {
  isLoading: layoutDefaultProps.isLoading,
};
export default Header;
