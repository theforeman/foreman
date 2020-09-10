import React from 'react';
import PropTypes from 'prop-types';
import { Button, Icon } from 'patternfly-react';
import './auditspage.scss';

import { translate as __ } from '../../../common/I18n';
import PageLayout from '../../common/PageLayout/PageLayout';
import AuditsTable from './components/AuditsTable';
import { AUDITS_SEARCH_PROPS, AUDITS_MANUAL_URL } from '../constants';
import { useForemanVersion } from '../../../Root/Context/ForemanContext';

const AuditsPage = ({
  searchQuery,
  fetchAndPush,
  isLoading,
  hasData,
  ...props
}) => {
  const foremanVersion = useForemanVersion();
  return (
    <PageLayout
      header={__('Audits')}
      searchable
      searchProps={AUDITS_SEARCH_PROPS}
      searchQuery={searchQuery}
      isLoading={isLoading && hasData}
      onSearch={search => fetchAndPush({ searchQuery: search, page: 1 })}
      onBookmarkClick={search => fetchAndPush({ searchQuery: search, page: 1 })}
      toolbarButtons={
        <Button href={AUDITS_MANUAL_URL(foremanVersion)} className="btn-docs">
          <Icon type="pf" name="help" />
          {__(' Documentation')}
        </Button>
      }
    >
      <AuditsTable
        fetchAndPush={fetchAndPush}
        isLoading={isLoading}
        hasData={hasData}
        {...props}
      />
    </PageLayout>
  );
};

AuditsPage.propTypes = {
  searchQuery: PropTypes.string.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  hasData: PropTypes.bool.isRequired,
};

export default AuditsPage;
