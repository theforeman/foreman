import React from 'react';
import { Spinner } from '@patternfly/react-core';
import './loadingpage.scss';

const LoadingPage = () => (
  <div id="loading-page">
    <Spinner isSVG size="xl" aria-label="Loading Page" />
  </div>
);

export default LoadingPage;
