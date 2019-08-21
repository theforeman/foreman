import React from 'react';
import { Button, Icon } from 'patternfly-react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const DocumentationButton = ({ url, text }) => (
  <Button href={url} className="btn-docs">
    <Icon type="pf" name="help" />
    {` ${text}`}
  </Button>
);

DocumentationButton.propTypes = {
  url: PropTypes.string.isRequired,
  text: PropTypes.string,
};

DocumentationButton.defaultProps = {
  text: __('Documentation'),
};

export default DocumentationButton;
