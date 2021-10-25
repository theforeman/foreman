import React from 'react';
import PropTypes from 'prop-types';
import { PageHeader, Brand } from '@patternfly/react-core';
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
  <PageHeader
    logo={
      <React.Fragment>
        <Brand src={logo} alt={brand} href={root} />
        <span className="navbar-brand-txt">
          <span>{brand}</span>
        </span>
      </React.Fragment>
    }
    logoProps={{ href: root }}
    showNavToggle
    onNavToggle={onNavToggle}
    headerTools={<HeaderToolbar {...props} isLoading={isLoading} />}
  />
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
