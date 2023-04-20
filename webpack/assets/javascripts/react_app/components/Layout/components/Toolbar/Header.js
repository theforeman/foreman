import React from 'react';
import PropTypes from 'prop-types';
import {
  Brand,
  Masthead,
  MastheadToggle,
  MastheadMain,
  MastheadBrand,
  MastheadContent,
  Button,
} from '@patternfly/react-core';
import { BarsIcon } from '@patternfly/react-icons';

import {
  layoutPropTypes,
  layoutDefaultProps,
  dataPropType,
} from '../../LayoutHelper';
import HeaderToolbar from './HeaderToolbar';

const Header = ({
  data: { logo, brand, root, ...props },
  onNavToggle,
  isLoading,
}) => (
  <Masthead display={{ default: 'inline' }}>
    <MastheadToggle>
      <Button onClick={onNavToggle} variant="plain">
        <BarsIcon />
      </Button>
    </MastheadToggle>
    <MastheadMain>
      <MastheadBrand href={root}>
        <React.Fragment>
          <Brand src={logo} alt={brand} href={root} />
          <span className="navbar-brand-txt">
            <span>{brand}</span>
          </span>
        </React.Fragment>
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
  onNavToggle: PropTypes.func.isRequired,
};

Header.defaultProps = {
  isLoading: layoutDefaultProps.isLoading,
};
export default Header;
