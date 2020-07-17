import React from 'react';
import { useDispatch } from 'react-redux';
import { push } from 'connected-react-router';
import { Button } from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';
import EmptyStatePattern from './EmptyStatePattern';
import { defaultEmptyStatePropTypes } from './EmptyStatePropTypes';

const DefaultEmptyState = props => {
  const {
    icon,
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
  icon: PlusCircleIcon,
  secondaryActions: [],
};

export default DefaultEmptyState;
