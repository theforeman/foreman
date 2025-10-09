import React from 'react';

import {
  Card,
  CardBody,
  CardTitle,
  CardFooter,
  Button,
  Icon,
} from '@patternfly/react-core';
import { ExternalLinkSquareAltIcon } from '@patternfly/react-icons';

import { translate as __ } from '../../../../common/I18n';
import { getUpgradeURL } from '../../../../common/helpers';

const DocumentationCard = () => (
  <Card isFlat ouiaId="upgrade-docs-documentation-card">
    <CardTitle component="h4">{__('Upgrade documentation')}</CardTitle>
    <CardBody>
      {__(
        'Detailed instructions to guide you through each stage of the upgrade process.'
      )}
    </CardBody>
    <CardFooter>
      <Button
        ouiaId="upgrade-docs-button"
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
        href={getUpgradeURL('documentation')}
      >
        {__('View upgrade documentation')}
      </Button>
    </CardFooter>
  </Card>
);

export default DocumentationCard;
