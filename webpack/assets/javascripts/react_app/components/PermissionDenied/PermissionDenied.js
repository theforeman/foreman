import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';
import { EmptyStatePattern as EmptyState } from '../common/EmptyState';

const PermissionDenied = ({ missingPermissions, primaryButton }) => {
  const description = (
    <span>
      {__('You are not authorized to perform this action.')}
      <br />
      {__(
        'Please request one of the required permissions listed below from a Foreman administrator:'
      )}
      <br />
    </span>
  );

  const doc = (
    <ul className="list-unstyled">
      {missingPermissions.map(permission => (
        <li key={permission}>
          <strong>{permission}</strong>
        </li>
      ))}
    </ul>
  );

  return (
    <EmptyState
      iconType="fa"
      icon="lock"
      header={__('Permission Denied')}
      description={description}
      documentation={doc}
      action={primaryButton}
    />
  );
};

PermissionDenied.propTypes = {
  missingPermissions: PropTypes.array,
  primaryButton: PropTypes.node,
};

PermissionDenied.defaultProps = {
  missingPermissions: ['unknown'],
  primaryButton: null,
};

export default PermissionDenied;
