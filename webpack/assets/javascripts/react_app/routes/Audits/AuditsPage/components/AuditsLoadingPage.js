import React from 'react';
import Skeleton from 'react-loading-skeleton';
import './auditsloading.scss';

const AuditsLoadingPage = () => (
  <div id="audits-empty-table">
    <Skeleton count={5} />
  </div>
);

export default AuditsLoadingPage;
