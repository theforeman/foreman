import React from 'react';
import { EmptyState as PfEmptyState, Button } from 'patternfly-react';

const EmptyState = (props) => {
  const {
    icon = 'add-circle-o',
    header,
    description,
    documentation: {
      label = __('For more information please see'),
      buttonLabel = __('Documentation'),
      url,
    },
    action,
    secondayActions,
  } = props;

  return (
    <PfEmptyState>
      <PfEmptyState.Icon type="pf" name={icon} />
      <PfEmptyState.Title>{header}</PfEmptyState.Title>
      <PfEmptyState.Info>{description}</PfEmptyState.Info>
      {url &&
        <PfEmptyState.Help>
         {label}
          <a href={url}> {buttonLabel} </a>
        </PfEmptyState.Help>
      }
      <PfEmptyState.Action>
        <Button href={action.url} bsStyle="primary" bsSize="large">
          {action.title}
        </Button>
      </PfEmptyState.Action>
      {secondayActions && (
        <PfEmptyState.Action secondary>
          {secondayActions.map(item => (
            <Button href={action.url} title={action.title}>
              {item.title}
            </Button>
          ))}
        </PfEmptyState.Action>
      )}
    </PfEmptyState>
  );
};
export default EmptyState;
