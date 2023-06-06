import React from 'react';
import { useDispatch } from 'react-redux';
import { push } from 'connected-react-router';
import { Button } from '@patternfly/react-core';
import EmptyStatePattern from './EmptyStatePattern';
import { defaultEmptyStatePropTypes } from './EmptyStatePropTypes';

const DefaultEmptyState = props => {
  const {
    icon,
    iconType,
    header,
    description,
    documentation,
    action,
    secondaryActions,
  } = props;

  const dispatch = useDispatch();
  const actionButtonClickHandler = ({ url, onClick }) => {
    if (onClick) onClick();
    else if (url) dispatch(push(url));
  };

  const ActionButton = action ? (
    <Button
      ouiaId="empty-state-action-button"
      component="a"
      onClick={() => actionButtonClickHandler(action)}
      variant="primary"
    >
      {action.title}
    </Button>
  ) : null;

  const SecondaryButton = secondaryActions
    ? secondaryActions.map(({ title, url, onClick }) => (
        <Button
          ouiaId="empty-state-secondary-action-button"
          component="a"
          key={`sec-button-${title}`}
          onClick={() => actionButtonClickHandler({ url, onClick })}
          variant="secondary"
        >
          {title}
        </Button>
      ))
    : null;

  return (
    <EmptyStatePattern
      icon={icon}
      iconType={iconType}
      header={header}
      description={description}
      documentation={documentation}
      action={ActionButton}
      secondaryActions={SecondaryButton}
    />
  );
};

DefaultEmptyState.propTypes = defaultEmptyStatePropTypes;

DefaultEmptyState.defaultProps = {
  icon: 'add-circle-o',
  secondaryActions: [],
  iconType: 'pf',
};

export default DefaultEmptyState;
