import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Button, Col, Icon } from '@theforeman/vendor/patternfly-react';
import { translate as __ } from '../../../common/I18n';

const SearchButton = ({ className, children, ...props }) => (
  <Button {...props} className={`autocomplete-search-btn ${className}`}>
    <Icon name="search" />
    <Col className="autocomplete-search-btn-text" xsHidden>
      &nbsp;
      {children}
    </Col>
  </Button>
);

SearchButton.propTypes = {
  className: PropTypes.string,
  children: PropTypes.node,
};

SearchButton.defaultProps = {
  className: '',
  children: __('Search'),
};

export default SearchButton;
