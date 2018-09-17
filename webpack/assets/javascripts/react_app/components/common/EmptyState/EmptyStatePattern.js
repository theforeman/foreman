import React from 'react';
import { EmptyState as PfEmptyState } from 'patternfly-react';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';

const EmptyStatePattern = props => {
  const { documentation, action, secondaryActions } = props;
  return (
    <PfEmptyState>
      <PfEmptyState.Icon type="pf" name={props.icon} />
      <PfEmptyState.Title>{props.header}</PfEmptyState.Title>
      <PfEmptyState.Info>{props.description}</PfEmptyState.Info>
      {documentation && <PfEmptyState.Help>{documentation}</PfEmptyState.Help>}
      {action && <PfEmptyState.Action>{action}</PfEmptyState.Action>}
      {secondaryActions && (
        <PfEmptyState.Action secondary>{secondaryActions}</PfEmptyState.Action>
      )}
    </PfEmptyState>
  );
};

EmptyStatePattern.propTypes = emptyStatePatternPropTypes;

export default EmptyStatePattern;
