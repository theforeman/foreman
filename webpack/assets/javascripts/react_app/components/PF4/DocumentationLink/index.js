import React from 'react';
import PropTypes from 'prop-types';
import { DropdownItem } from '@patternfly/react-core';
import { QuestionCircleIcon } from '@patternfly/react-icons';
import { newWindowOnClick } from '../../../common/helpers';
import { translate as __ } from '../../../../react_app/common/I18n';

const DocumentationLink = ({ href, children }) => (
  <DropdownItem
    key="documentationUrl"
    href={href}
    onClick={newWindowOnClick(href)}
  >
    <QuestionCircleIcon />
    {` ${children}`}
  </DropdownItem>
);

DocumentationLink.propTypes = {
  href: PropTypes.string.isRequired,
  children: PropTypes.node,
};

DocumentationLink.defaultProps = {
  children: __('Documentation'),
};

export default DocumentationLink;
