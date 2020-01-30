import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import PageLayout from '../../common/PageLayout/PageLayout';
import { SETTINGS_SEARCH_PROPS } from '../constants';
import SettingsPageContent from './components/SettingsPageContent';

const SettingsPage = ({
  pageParams,
  isLoading,
  hasData,
  fetchAndPush,
  hasError,
  errorMsg,
  groupedSettings,
}) => (
  <PageLayout
    header={__('Settings')}
    searchable
    searchProps={SETTINGS_SEARCH_PROPS}
    searchQuery={pageParams.search}
    isLoading={isLoading && hasData}
    onSearch={search => fetchAndPush({ search })}
    onBookmarkClick={search => fetchAndPush({ search })}
  >
    <SettingsPageContent
      groupedSettings={groupedSettings}
      hasData={hasData}
      hasError={hasError}
      isLoading={isLoading}
      errorMsg={errorMsg}
    />
  </PageLayout>
);

SettingsPage.propTypes = {
  pageParams: PropTypes.object.isRequired,
  isLoading: PropTypes.bool.isRequired,
  hasData: PropTypes.bool.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  hasError: PropTypes.bool.isRequired,
  errorMsg: PropTypes.object.isRequired,
  groupedSettings: PropTypes.object.isRequired,
};

export default SettingsPage;
