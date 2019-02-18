import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { MenuItem, Icon } from '@theforeman/vendor/patternfly-react';
import { newWindowOnClick } from '../../../common/helpers';
import { translate as __ } from '../../../../react_app/common/I18n';

const DocumentationLink = ({ href, children }) => (
  <MenuItem key="documentationUrl" href={href} onClick={newWindowOnClick(href)}>
    <Icon type="fa" name="question-circle" />
    {` ${children}`}
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
