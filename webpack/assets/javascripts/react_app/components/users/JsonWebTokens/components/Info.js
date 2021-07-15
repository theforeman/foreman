import React from 'react';
import { translate as __ } from '../../../../common/I18n';

const Info = () => (
  <>
    {__(
      'JSON web token (JWT) allow you to authenticate API requests without exposing your credentials.'
    )}
    <p>
      <code>
        curl &apos;/api/statuses&apos; -H &apos;Authorization: Bearer
        token-value&apos;
      </code>
    </p>
  </>
);

export default Info;
