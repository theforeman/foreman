import React from 'react';
import PropTypes from 'prop-types';
import { withRenderHandler } from '../../../../common/HOC';
import AuditsList from '../../../../components/AuditsList';
import AuditsLoadingPage from './AuditsLoadingPage';
import Pagination from '../../../../components/Pagination/Pagination';

const AuditsTable = ({
  audits,
  page,
  perPage,
  itemCount,
  fetchAndPush,
  perPageOptions,
}) => (
  <React.Fragment>
    <div id="audit-list">
      <AuditsList data={{ audits }} fetchAndPush={fetchAndPush} />
    </div>
    <div id="pagination">
      <Pagination
        data={{
          itemCount,
          viewType: 'table',
          classNames: { pagination_classes: 'audits-pagination' },
        }}
        pagination={{
          page,
          perPage,
          perPageOptions,
        }}
        onPageSet={newPage => fetchAndPush({ page: newPage })}
        onPerPageSelect={newPerPage =>
          fetchAndPush({ perPage: newPerPage, page: 1 })
        }
      />
    </div>
  </React.Fragment>
);

AuditsTable.propTypes = {
  audits: PropTypes.array.isRequired,
  page: PropTypes.number.isRequired,
  perPage: PropTypes.number.isRequired,
  itemCount: PropTypes.number.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  perPageOptions: PropTypes.array.isRequired,
};

export default withRenderHandler({
  Component: AuditsTable,
  LoadingComponent: AuditsLoadingPage,
});
