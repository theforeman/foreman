import React from 'react';
import { EmptyState as PfEmptyState } from 'patternfly-react';
import { emptyStatePatternPropTypes } from './EmptyStatePropTypes';

const EmptyStatePattern = props => {
  const {
    documentation,
    action,
    secondaryActions,
    icon,
    iconType,
    header,
    description,
  } = props;

  return (
    <PfEmptyState>
      <PfEmptyState.Icon type={iconType} name={icon} />
      <PfEmptyState.Title>{header}</PfEmptyState.Title>
      <PfEmptyState.Info>{description}</PfEmptyState.Info>
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
