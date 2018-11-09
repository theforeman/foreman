import React from 'react';
import PropTypes from 'prop-types';
import { MenuItem } from 'patternfly-react';
import Icon from '../Icon';
import { newWindowOnClick } from '../../../common/helpers';
import { translate as __ } from '../../../../react_app/common/I18n';

export const DocumentLinkContent = ({ children }) => (
  <React.Fragment>
    <Icon type="question-sign" className="icon-black" />
    {` ${children}`}
  </React.Fragment>
);

DocumentLinkContent.propTypes = {
  children: PropTypes.node,
};

DocumentLinkContent.defaultProps = {
  children: __('Documentation'),
};

const DocumentationLink = ({ href }) => (
  <MenuItem key="documentationUrl" href={href} onClick={newWindowOnClick(href)}>
    <DocumentLinkContent />
  </MenuItem>
);

DocumentationLink.propTypes = {
  href: PropTypes.string.isRequired,
};

export default DocumentationLink;
