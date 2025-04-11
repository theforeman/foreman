import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

const UserDetails = ({ isAuditLogin, userInfo, remoteAddress }) => {
  const {
    search_path: searchPath,
    display_name: UserDisplayName,
    audit_path: auditPath,
  } = userInfo;

  const title = __('Filter audits for this user only');

  const linkProps = {
    href: searchPath,
    className: 'user-info',
  };

  if (isAuditLogin) {
    return (
      <span className="pf-v5-u-font-weight-bold pf-v5-u-font-size-sm">
        <Tooltip content={title}>
          <a {...linkProps}>{UserDisplayName}</a>
        </Tooltip>
        <div>
          <a href={auditPath}>{__('Logged-in')}</a>
        </div>
      </span>
    );
  }

  return (
    <span className="pf-v5-u-font-weight-bold pf-v5-u-font-size-sm">
      <Tooltip content={title}>
        <a {...linkProps}>{UserDisplayName}</a>
      </Tooltip>
      {remoteAddress ? (
        <div className="gray-text">({remoteAddress})</div>
      ) : null}
    </span>
  );
};

UserDetails.propTypes = {
  userInfo: PropTypes.shape({
    search_path: PropTypes.string,
    display_name: PropTypes.string,
    audit_path: PropTypes.string,
  }).isRequired,
  isAuditLogin: PropTypes.bool,
  remoteAddress: PropTypes.string,
};

UserDetails.defaultProps = {
  isAuditLogin: false,
  remoteAddress: undefined,
};

export default UserDetails;
