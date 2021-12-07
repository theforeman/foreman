import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from '../../common/I18n';
import EmptyState from '../common/EmptyState';
import { foremanUrl } from '../../common/helpers';

export const WelcomeArchitecture = ({ canCreate }) => {
  const action = canCreate && {
    title: __('Create Architecture'),
    url: foremanUrl('/architectures/new'),
  };
  const description = (
    <>
      {__(
        'Before you proceed to using Foreman you should provide information about one or more architectures.'
      )}
      <br />
      <FormattedMessage
        id="architecture-message"
        defaultMessage={__(
          'Each entry represents a particular hardware architecture, most commonly {x86_64} or {i386}. Foreman also supports the Solaris operating system family, which includes {sparc} based systems.'
        )}
        values={{
          x86_64: <b>x86_64</b>,
          i386: <b>i386</b>,
          sparc: <b>sparc</b>,
        }}
      />
      <br />
      {__(
        'Each architecture can also be associated with more than one operating system and a selector block is provided to allow you to select valid combinations.'
      )}
    </>
  );

  return (
    <EmptyState
      icon="building"
      iconType="fa"
      header={__('Architectures')}
      description={description}
      action={action}
    />
  );
};

WelcomeArchitecture.propTypes = {
  canCreate: PropTypes.bool,
};

WelcomeArchitecture.defaultProps = {
  canCreate: false,
};
