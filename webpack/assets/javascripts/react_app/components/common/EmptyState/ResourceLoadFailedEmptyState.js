import React from 'react';
import { useHistory } from 'react-router-dom';
import { Button, EmptyStateVariant } from '@patternfly/react-core';
import { LockIcon, SearchIcon } from '@patternfly/react-icons';
import EmptyStatePattern from './EmptyStatePattern';
import { resourceLoadFailedEmptyStatePropTypes } from './EmptyStatePropTypes';
import { translate as __, sprintf } from '../../../common/I18n';
import { usePermissions } from '../../../common/hooks/Permissions/permissionHooks';
import { useForemanPermissions } from '../../../Root/Context/ForemanContext';

const FAILURE_REASON = {
  FORBIDDEN: 'forbidden',
  NOT_FOUND: 'not_found',
  UNKNOWN: 'unknown',
};

const resolveFailureReason = ({
  httpStatus,
  viewPermissions,
  hasViewPermission,
}) => {
  if (httpStatus === 403) return FAILURE_REASON.FORBIDDEN;
  if (viewPermissions?.length > 0 && !hasViewPermission) {
    return FAILURE_REASON.FORBIDDEN;
  }
  if (httpStatus === 404) return FAILURE_REASON.NOT_FOUND;
  if (viewPermissions?.length > 0 && hasViewPermission) {
    return FAILURE_REASON.NOT_FOUND;
  }
  return FAILURE_REASON.UNKNOWN;
};

const getDefaultDescription = (failureReason, resourceLabel, resourceId) => {
  const hasResourceId = resourceId !== null && resourceId !== undefined;

  switch (failureReason) {
    case FAILURE_REASON.FORBIDDEN:
      return hasResourceId
        ? sprintf(
            __('You do not have permission to view the %s with id %s.'),
            resourceLabel,
            resourceId
          )
        : sprintf(
            __('You do not have permission to view this %s.'),
            resourceLabel
          );
    case FAILURE_REASON.NOT_FOUND:
      return hasResourceId
        ? sprintf(
            __(
              'The %s with id %s could not be found. It may have been deleted or may not be available in your current organization or location scope.'
            ),
            resourceLabel,
            resourceId
          )
        : sprintf(
            __(
              'The %s could not be found. It may have been deleted or may not be available in your current organization or location scope.'
            ),
            resourceLabel
          );
    default:
      return hasResourceId
        ? sprintf(
            __('The %s with id %s could not be loaded.'),
            resourceLabel,
            resourceId
          )
        : sprintf(__('The %s could not be loaded.'), resourceLabel);
  }
};

const invokeFooterAction = (action, history) => {
  if (action.onClick) {
    action.onClick();
  } else if (action.url) {
    history.push(action.url);
  }
};

const ResourceLoadFailedEmptyState = ({
  resourceLabel,
  resourceId,
  header,
  description,
  errorMessage,
  httpStatus,
  viewPermissions,
  requiredPermissions,
  primaryAction,
  secondaryActions,
  showBackButton,
  backButtonLabel,
  icon,
  variant,
  ouiaIdPrefix,
  ...props
}) => {
  const history = useHistory();
  const userPermissions = useForemanPermissions();
  const hasViewPermission = usePermissions(viewPermissions || []);
  const failureReason = resolveFailureReason({
    httpStatus,
    viewPermissions,
    hasViewPermission,
  });
  const isForbidden = failureReason === FAILURE_REASON.FORBIDDEN;

  const missingViewPermissions =
    viewPermissions?.filter(permission => !userPermissions.has(permission)) ||
    [];

  let permissionsToList = requiredPermissions;
  if (isForbidden && missingViewPermissions.length > 0) {
    permissionsToList = missingViewPermissions;
  }

  const resolvedHeader =
    header ||
    (isForbidden
      ? __('Permission denied')
      : sprintf(__('Unable to load %s'), resourceLabel));

  const resolvedIcon = icon ?? (isForbidden ? <LockIcon /> : <SearchIcon />);

  const defaultDescription = getDefaultDescription(
    failureReason,
    resourceLabel,
    resourceId
  );

  const descriptionContent = (
    <React.Fragment>
      <p>
        {description ?? defaultDescription}
        {permissionsToList?.length > 0 ? (
          <React.Fragment>
            {' '}
            {__('Accessing this page requires the following permissions:')}{' '}
            {permissionsToList.map((permission, index) => (
              <React.Fragment key={permission}>
                {index > 0 ? ', ' : null}
                <strong>{permission}</strong>
              </React.Fragment>
            ))}
          </React.Fragment>
        ) : null}
      </p>
      {errorMessage ? (
        <p>
          {__('Server returned: ')} {errorMessage}
        </p>
      ) : null}
    </React.Fragment>
  );

  const renderFooterButton = (
    { label, onClick, url, ouiaId },
    buttonVariant,
    defaultOuiaId
  ) => (
    <Button
      ouiaId={ouiaId || defaultOuiaId}
      variant={buttonVariant}
      onClick={() => invokeFooterAction({ onClick, url }, history)}
    >
      {label}
    </Button>
  );

  const footerSecondaryActions = (
    <React.Fragment>
      {secondaryActions.map((action, index) => (
        <React.Fragment
          key={action.ouiaId || `${ouiaIdPrefix}-secondary-action-${index}`}
        >
          {renderFooterButton(
            action,
            'link',
            `${ouiaIdPrefix}-secondary-action-${index}`
          )}
        </React.Fragment>
      ))}
      {showBackButton
        ? renderFooterButton(
            {
              label: backButtonLabel,
              onClick: () => history.goBack(),
              ouiaId: `${ouiaIdPrefix}-go-back`,
            },
            'link',
            `${ouiaIdPrefix}-go-back`
          )
        : null}
    </React.Fragment>
  );

  return (
    <EmptyStatePattern
      variant={variant}
      icon={resolvedIcon}
      header={resolvedHeader}
      description={descriptionContent}
      action={renderFooterButton(
        primaryAction,
        'primary',
        `${ouiaIdPrefix}-primary-action`
      )}
      secondaryActions={footerSecondaryActions}
      {...props}
    />
  );
};

ResourceLoadFailedEmptyState.propTypes = resourceLoadFailedEmptyStatePropTypes;

ResourceLoadFailedEmptyState.defaultProps = {
  resourceId: null,
  header: null,
  description: null,
  errorMessage: null,
  httpStatus: null,
  viewPermissions: null,
  requiredPermissions: null,
  secondaryActions: [],
  showBackButton: true,
  backButtonLabel: __('Return to the previous page'),
  icon: null,
  variant: EmptyStateVariant.lg,
  ouiaIdPrefix: 'resource-load-failed-empty-state',
};

export default ResourceLoadFailedEmptyState;
