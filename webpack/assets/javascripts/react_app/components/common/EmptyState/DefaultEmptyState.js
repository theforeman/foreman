import React from 'react';
import EmptyStatePattern from './EmptyStatePattern';
import PrimaryActionButton from './EmptyStatePrimaryActionButton';
import SecondaryActionButtons from './EmptyStateSecondaryActionButtons';
import { defaultEmptyStatePropTypes } from './EmptyStatePropTypes';
import { translate as __ } from '../../../common/I18n';

const documentationBlock = ({
  url,
  label = __('For more information please see'),
  buttonLabel = __('Documentation'),
}) =>
  url && (
    <React.Fragment>
      {label}{' '}
      <a href={url} target="_blank" rel="noopener noreferrer">
        {buttonLabel}
      </a>
    </React.Fragment>
  );

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

  return (
    <EmptyStatePattern
      icon={icon}
      iconType={iconType}
      header={header}
      description={description}
      documentation={documentation ? documentationBlock(documentation) : null}
      action={<PrimaryActionButton action={action} />}
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
