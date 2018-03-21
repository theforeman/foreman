import React from 'react';
import PropTypes from 'prop-types';
import { Button, Col, Icon } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';

const SearchButton = ({ className, ...props }) => (
  <Button {...props} className={`autocomplete-search-btn ${className}`}>
    <Icon name="search" />
    <Col className="autocomplete-search-btn-text" xsHidden>
      &nbsp;
      {__('Search')}
    </Col>
  </Button>
);

SearchButton.propTypes = {
  className: PropTypes.string,
};

SearchButton.defaultProps = {
  className: '',
};

export default SearchButton;
