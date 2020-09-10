import React from 'react';
import { Spinner } from 'patternfly-react';
import './loadingpage.scss';

const LoadingPage = () => (
  <div id="loading-page">
    <Spinner loading size="lg" />
  </div>
);

export default LoadingPage;
