import React from 'react';
import { translate as __ } from '../../common/I18n';
import EmptyState from '../common/EmptyState';
import { getManualURL, getWikiURL } from '../../common/helpers';

export const WelcomeConfigReports = () => {
  const content = __(`If you wish to configure Puppet to forward its reports to Foreman, 
  please follow <a href=${getManualURL(
    '3.5.4PuppetReports'
  )}>setting up reporting</a> and
  <a href=${getWikiURL('Mail_Notifications')}>e-mail reporting</a>`);
  const description = (
    <>
      {__("You don't seem to have any reports.")}
      <div dangerouslySetInnerHTML={{ __html: content }} />
    </>
  );
  return (
    <EmptyState
      icon="book"
      iconType="fa"
      header={__('Reports')}
      description={description}
      documentation={{ url: getManualURL('3.5.4PuppetReports') }}
    />
  );
};
