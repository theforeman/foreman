import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import RelativeDateTime from '../../../common/dates/RelativeDateTime';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

const PersonalAccessToken = ({
  deletePersonalAccessToken,
  deletable,
  revokePersonalAccessToken,
  id,
  name,
  created_at: createdAt,
  expires_at: expiresAt,
  last_used_at: lastUsedAt,
  user_id: userId,
  'active?': isActive,
  'revoked?': isRevoked,
}) => (
  <tr>
    <td>{name}</td>
    <td>
      <RelativeDateTime date={createdAt} />
    </td>
    <td>
      {(isRevoked && __('Revoked')) || (!expiresAt && __('Never')) || (
        <RelativeDateTime date={expiresAt} />
      )}
    </td>
    <td>{lastUsedAt ? <RelativeDateTime date={lastUsedAt} /> : __('Never')}</td>
    <td>
      {isActive && (
        <Button
          onClick={() => revokePersonalAccessToken(id)}
          size="sm"
          variant="link"
          isInline
          ouiaId="revoke-personal-access-token-button"
        >
          {__('Revoke')}
        </Button>
      )}
      {!isActive && deletable && (
        <Button
          onClick={() => deletePersonalAccessToken(id)}
          size="sm"
          variant="link"
          isDanger
          isInline
          ouiaId="delete-personal-access-token-button"
        >
          {__('Delete')}
        </Button>
      )}
    </td>
  </tr>
);

PersonalAccessToken.propTypes = {
  id: PropTypes.number.isRequired,
  deletePersonalAccessToken: PropTypes.func,
  deletable: PropTypes.bool,
  user_id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  created_at: PropTypes.string.isRequired,
  revokePersonalAccessToken: PropTypes.func,
  expires_at: PropTypes.string,
  last_used_at: PropTypes.string,
  'active?': PropTypes.bool.isRequired,
  'revoked?': PropTypes.bool.isRequired,
};

PersonalAccessToken.defaultProps = {
  deletePersonalAccessToken: noop,
  deletable: false,
  revokePersonalAccessToken: noop,
  expires_at: null,
  last_used_at: null,
};

export default PersonalAccessToken;
