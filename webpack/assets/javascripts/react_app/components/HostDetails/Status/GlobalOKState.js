import React from 'react';
import { Title, EmptyState, EmptyStateIcon } from '@patternfly/react-core';
import { OkIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';

const GlobalOKState = () => (
  <EmptyState style={{ marginTop: '-1px' }} isFullHeight>
    <EmptyStateIcon icon={OkIcon} />
    <Title size="lg" headingLevel="h4">
      {__('All Statuses are OK')}
    </Title>
  </EmptyState>
);

export default GlobalOKState;
