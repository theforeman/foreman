import React from 'react';
import TimeAgo from '../../common/TimeAgo';
import Button from '../../common/forms/Button';

/* eslint-disable camelcase */
export default ({
  id,
  name,
  created_at,
  expires_at,
  last_used_at,
  user_id,
  revocable,
  revokeToken
}) => (
  <tr>
    <td>{name}</td>
    <td>
      <TimeAgo date={created_at} />
    </td>
    <td>
      <TimeAgo date={expires_at} />
    </td>
    <td>
      <TimeAgo date={last_used_at} />
    </td>
    <td>
      {revocable && (
        <Button onClick={revokeToken} className="btn-sm btn-default">{__('Revoke')}</Button>
      )}
    </td>
  </tr>
);
