import React from 'react';
import EmptyStatePattern from './EmptyStatePattern';
import PrimaryActionButton from './EmptyStatePrimaryActionButton';
import SecondaryActionButtons from './EmptyStateSecondaryActionButtons';
import { defaultEmptyStatePropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';

const DefaultEmptyState = props => {
  const {
    icon,
    iconType,
    header,
    description,
    documentation: {
      url,
      label = __('For more information please see'),
      buttonLabel = __('Documentation'),
    } = {},
    action,
    secondaryActions,
  } = props;

  const documentationBlock = url ? (
    <React.Fragment>
      {label}{' '}
      <a href={url} target="_blank" rel="noopener noreferrer">
        {buttonLabel}
      </a>
    </React.Fragment>
  ) : null;

  return (
    <EmptyStatePattern
      icon={icon}
      iconType={iconType}
      header={header}
      description={description}
      documentation={documentationBlock}
      action={action ? <PrimaryActionButton action={action} /> : null}
      secondaryActions={<SecondaryActionButtons actions={secondaryActions} />}
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
