import React from 'react';
import PropTypes from 'prop-types';

import {
  TextContent,
  Text,
  TextVariants,
  Button,
  Icon,
} from '@patternfly/react-core';
import { ExternalLinkSquareAltIcon } from '@patternfly/react-icons';

import { translate as __ } from '../../../../common/I18n';
import { getSupportURL } from '../../../../common/helpers';

const DocumentationFooter = ({ helpDesc, helpLinkText }) => (
  <TextContent>
    <Text
      ouiaId="upgrade-docs-footer-card-text-help"
      component={TextVariants.h6}
    >
      {__('Need help?')}
    </Text>
    <Text
      ouiaId="upgrade-docs-footer-card-text-desc"
      component={TextVariants.p}
    >
      {helpDesc}
    </Text>
    <Button
      ouiaId="upgrade-page-help-button"
      component="a"
      variant="link"
      icon={
        <Icon>
          <ExternalLinkSquareAltIcon />
        </Icon>
      }
      iconPosition="right"
      target="_blank"
      isInline
      href={getSupportURL()}
    >
      {helpLinkText}
    </Button>
  </TextContent>
);
DocumentationFooter.propTypes = {
  helpLinkText: PropTypes.string,
  helpDesc: PropTypes.string,
};
DocumentationFooter.defaultProps = {
  helpDesc: __(
    'Need help with Foreman? Got a different type of question? Ask them all on our community forum!'
  ),
  helpLinkText: __('Visit the community forum'),
};

export default DocumentationFooter;
