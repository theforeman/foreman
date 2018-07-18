import React from 'react';
import PropTypes from 'prop-types';
import { MenuItem } from 'patternfly-react';
import Icon from '../Icon';
import { newWindowOnClick } from '../../../common/helpers';

// TODO: move children's default value to defaultProps once "Fixes #17263" is merged
export const DocumentLinkContent = ({ children = __('Documentation') }) => (
  <React.Fragment>
    <Icon type="question-sign" className="icon-black" />
    {` ${children}`}
  </React.Fragment>
);

DocumentLinkContent.propTypes = {
  children: PropTypes.node,
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
