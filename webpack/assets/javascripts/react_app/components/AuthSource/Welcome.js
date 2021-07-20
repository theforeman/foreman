import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';
import EmptyState from '../common/EmptyState';
import { getManualURL } from '../../common/helpers';

export const WelcomeAuthSource = ({ canCreate }) => {
  const content = __(
    `The authentication process currently requires an LDAP provider, such as <em>FreeIPA</em>, <em>OpenLDAP</em> or <em>Microsoft's Active Directory</em>.`
  );
  const description = (
    <>
      {__(
        'Foreman can use LDAP based service for user information and authentication.'
      )}
      <div dangerouslySetInnerHTML={{ __html: content }} />
      <a href={getManualURL('4.1.1LDAPAuthentication')}>
        {__('Learn more about LDAP authentication in the documentation.')}
      </a>
      <br />
      {__(
        'Foreman can use External service for user information and authentication.'
      )}
      <br />
      <a href={getManualURL('5.7ExternalAuthentication')}>
        {__('Learn more about External authentication in the documentation.')}
      </a>
    </>
  );
  const action = canCreate && {
    title: __('Create LDAP Authentication Source'),
    url: 'auth_source_ldaps/new',
  };

  return (
    <EmptyState
      icon="users"
      iconType="fa"
      header={__('Authentication Sources')}
      description={description}
      action={action}
    />
  );
};

WelcomeAuthSource.propTypes = {
  canCreate: PropTypes.bool,
};

WelcomeAuthSource.defaultProps = {
  canCreate: false,
};
