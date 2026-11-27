import React from 'react';
import PropTypes from 'prop-types';

import { Content, ContentVariants, Button, Icon } from '@patternfly/react-core';
import { ExternalLinkSquareAltIcon } from '@patternfly/react-icons';

import { translate as __ } from '../../../../common/I18n';
import { getSupportURL } from '../../../../common/helpers';

const DocumentationFooter = ({ helpDesc, helpLinkText }) => (
  <Content>
    <Content
      ouiaId="upgrade-docs-footer-card-text-help"
      component={ContentVariants.h6}
    >
      {__('Need help?')}
    </Content>
    <Content
      ouiaId="upgrade-docs-footer-card-text-desc"
      component={ContentVariants.p}
    >
      {helpDesc}
    </Content>
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
  </Content>
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
