import React from 'react';
import PropTypes from 'prop-types';
import { withRenderHandler } from '../../../../common/HOC';
import AuditsList from '../../../../components/AuditsList';
import AuditsLoadingPage from './AuditsLoadingPage';
import Pagination from '../../../../components/Pagination';

const AuditsTable = ({ audits, itemCount, fetchAndPush }) => (
  <React.Fragment>
    <div id="audit-list">
      <AuditsList data={{ audits }} fetchAndPush={fetchAndPush} />
    </div>
    <Pagination itemCount={itemCount} onChange={fetchAndPush} noSidePadding />
  </React.Fragment>
);

AuditsTable.propTypes = {
  audits: PropTypes.array.isRequired,
  itemCount: PropTypes.number.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
};

export default withRenderHandler({
  Component: AuditsTable,
  LoadingComponent: AuditsLoadingPage,
});
