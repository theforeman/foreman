import React from 'react';
import PropTypes from 'prop-types';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import { translate as __ } from '../../common/I18n';

const UserDetails = ({ isAuditLogin, userInfo, remoteAddress }) => {
  const {
    search_path: searchPath,
    display_name: UserDisplayName,
    audit_path: auditPath,
  } = userInfo;

  const linkProps = {
    href: searchPath,
    title: __('Filter audits for this user only'),
    className: 'user-info',
  };

  if (isAuditLogin) {
    return (
      <span className="user-grid">
        <EllipsisWithTooltip>
          <span>
            <a {...linkProps}>{UserDisplayName}</a>
          </span>
        </EllipsisWithTooltip>
        <span>
          <a href={auditPath}>{__('Logged-in')}</a>
        </span>
      </span>
    );
  }

  return (
    <span className="user-grid">
      <EllipsisWithTooltip>
        <span>
          <a {...linkProps}>{UserDisplayName}</a>
        </span>
      </EllipsisWithTooltip>
      {remoteAddress ? (
        <span className="gray-text">({remoteAddress})</span>
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
