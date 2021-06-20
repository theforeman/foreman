import React from 'react';
import PropTypes from 'prop-types';
import { MenuItem, Icon } from 'patternfly-react';
import { newWindowOnClick } from '../../../common/helpers';
import { translate as __ } from '../../../../react_app/common/I18n';

const DocumentationLink = ({ href, children }) => (
  <MenuItem key="documentationUrl" onClick={newWindowOnClick(href)}>
    <Icon type="fa" name="question-circle" /> {children}
  </MenuItem>
);

DocumentationLink.propTypes = {
  href: PropTypes.string.isRequired,
  children: PropTypes.node,
};

DocumentationLink.defaultProps = {
  children: __('Documentation'),
};

export default DocumentationLink;
