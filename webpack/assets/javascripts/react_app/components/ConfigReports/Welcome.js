import React from 'react';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from '../../common/I18n';
import EmptyState from '../common/EmptyState';
import { getManualURL, getWikiURL } from '../../common/helpers';

export const WelcomeConfigReports = () => {
  const description = (
    <>
      {__("You don't seem to have any reports.")}

      <br />
      <FormattedMessage
        id="report-manual"
        defaultMessage={__(
          'If you wish to configure Puppet to forward its reports to Foreman, please follow {settingUpPuppetReports} and {emailReporting}'
        )}
        values={{
          settingUpPuppetReports: (
            <a href={getManualURL('3.5.4PuppetReports')}>
              {__('setting up reporting')}
            </a>
          ),
          emailReporting: (
            <a href={getWikiURL('Mail_Notifications')}>
              {__('e-mail reporting')}
            </a>
          ),
        }}
      />
      <br />
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
