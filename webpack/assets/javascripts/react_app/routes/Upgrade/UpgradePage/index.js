import React from 'react';

import { TextContent, Text, TextVariants } from '@patternfly/react-core';

import PageLayout from '../../common/PageLayout/PageLayout';
import Slot from '../../../components/common/Slot';
import { translate as __ } from '../../../common/I18n';

import DocumentationCard from './components/DocumentationCard';
import DocumentationFooter from './components/DocumentationFooter';

const UpgradePage = () => (
  <PageLayout header={__('Foreman upgrade')} searchable={false}>
    <>
      <TextContent>
        <Text ouiaId="upgrade-page-top-msg" component={TextVariants.p}>
          {__(
            'Stay secure, supported, and up-to-date by upgrading to the latest version of Foreman.' +
              ' Access new features, critical updates, and enhanced compatibility with minimal disruption.'
          )}
        </Text>
      </TextContent>
      <br />
      <br />
      <Slot id="upgrade-page-upgrade-docs">
        <DocumentationCard key="upgrade-documentation-card" />
      </Slot>
      <br />
      <br />
      <Slot id="upgrade-page-additional-docs" />
      <br />
      <br />
      <Slot id="upgrade-page-footer">
        <DocumentationFooter key="upgrade-footer-card" />
      </Slot>
    </>
  </PageLayout>
);

export default UpgradePage;
