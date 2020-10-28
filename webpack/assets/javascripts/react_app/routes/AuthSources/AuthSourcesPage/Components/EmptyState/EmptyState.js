import React from 'react';
import {
  Title,
  Button,
  EmptyState,
  EmptyStateVariant,
  EmptyStateIcon,
  EmptyStateBody,
  // EmptyStateSecondaryActions,
} from '@patternfly/react-core';
import { CubesIcon } from '@patternfly/react-icons';

const AuthSourceEmptyState = () => (
  <EmptyState variant={EmptyStateVariant.full}>
    <EmptyStateIcon icon={CubesIcon} />
    <Title headingLevel="h5" size="lg">
      Auth Sources
    </Title>
    <EmptyStateBody>
      This represents an the empty state pattern in Patternfly 4. Hopefully it's
      simple enough to use but flexible enough to meet a variety of needs.
    </EmptyStateBody>
    <Button variant="primary">Create LDAP</Button>
  </EmptyState>
);

export default AuthSourceEmptyState;
