import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';

import PageLayout from '../common/PageLayout/PageLayout';
import AuditsList from '../../components/AuditsList';
import Pagination from '../../components/Pagination/Pagination';
import { documentationURL } from '../../common/urlHelpers';

const AuditsPage = ({
  data: { searchProps, audits, pagination, searchable },
}) => (
  <PageLayout
    header={__('Audits')}
    searchable={searchable}
    searchProps={searchProps}
    documentationURL={documentationURL('4.1.4Auditing')}
  >
    <div id="audit-list">
      <AuditsList data={audits} />
    </div>
    <div id="pagination">
      <Pagination data={pagination} />
    </div>
  </PageLayout>
);

AuditsPage.propTypes = {
  data: PropTypes.shape({
    searchProps: PropTypes.shape({
      autocomplete: PropTypes.shape({
        results: PropTypes.array,
        searchQuery: PropTypes.string,
        url: PropTypes.string,
        useKeyShortcuts: PropTypes.bool,
      }),
      controller: PropTypes.string,
      bookmarks: PropTypes.shape({
        text: PropTypes.string,
        query: PropTypes.string,
      }),
    }),
    audits: PropTypes.shape({
      audits: PropTypes.array.isRequired,
    }).isRequired,
    pagination: PropTypes.shape({
      viewType: PropTypes.string,
      perPageOptions: PropTypes.arrayOf(PropTypes.number),
      itemCount: PropTypes.number,
      perPage: PropTypes.number,
    }).isRequired,
    searchable: PropTypes.bool,
  }).isRequired,
};

export default AuditsPage;
