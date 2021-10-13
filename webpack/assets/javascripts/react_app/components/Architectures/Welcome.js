import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';
import EmptyState from '../common/EmptyState';
import { foremanUrl } from '../../common/helpers';

export const WelcomeArchitecture = ({ canCreate }) => {
  const action = canCreate && {
    title: __('Create Architecture'),
    url: foremanUrl('/architectures/new'),
  };
  const content =
    __(`Each entry represents a particular hardware architecture, most commonly <b>x86_64</b> or <b>i386</b>.
  Foreman also supports the Solaris operating system family, which includes <b>sparc</b> based systems.`);
  const description = (
    <>
      {__(
        'Before you proceed to using Foreman you should provide information about one or more architectures.'
      )}
      <div dangerouslySetInnerHTML={{ __html: content }} />
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
