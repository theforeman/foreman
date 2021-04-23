import React from 'react';
import PropTypes from 'prop-types';

import ConfigParams from './fields/ConfigParams';
import Packages from './fields/Packages';
import Repository from './fields/Repository';
import TokenLifeTime from './fields/TokenLifeTime';

const Advanced = ({
  configParams,
  setupRemoteExecution,
  setupInsights,
  handleInsights,
  handleRemoteExecution,
  jwtExpiration,
  handleJwtExpiration,
  handleInvalidField,
  packages,
  handlePackages,
  repo,
  handleRepo,
  repoGpgKeyUrl,
  handleRepoGpgKeyUrl,
  isLoading,
}) => (
  <>
    <ConfigParams
      configParams={configParams}
      setupRemoteExecution={setupRemoteExecution}
      setupInsights={setupInsights}
      handleInsights={handleInsights}
      handleRemoteExecution={handleRemoteExecution}
      isLoading={isLoading}
    />
    <Packages
      packages={packages}
      handlePackages={handlePackages}
      configParams={configParams}
      isLoading={isLoading}
    />
    <Repository
      repo={repo}
      handleRepo={handleRepo}
      repoGpgKeyUrl={repoGpgKeyUrl}
      handleRepoGpgKeyUrl={handleRepoGpgKeyUrl}
      isLoading={isLoading}
    />
    <TokenLifeTime
      value={jwtExpiration}
      onChange={handleJwtExpiration}
      handleInvalidField={handleInvalidField}
      isLoading={isLoading}
    />
  </>
);

Advanced.propTypes = {
  configParams: PropTypes.object,
  setupRemoteExecution: PropTypes.string,
  setupInsights: PropTypes.string,
  handleInsights: PropTypes.func.isRequired,
  handleRemoteExecution: PropTypes.func.isRequired,
  jwtExpiration: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleJwtExpiration: PropTypes.func.isRequired,
  handleInvalidField: PropTypes.func.isRequired,
  packages: PropTypes.string,
  repo: PropTypes.string,
  repoGpgKeyUrl: PropTypes.string,
  handlePackages: PropTypes.func.isRequired,
  handleRepo: PropTypes.func.isRequired,
  handleRepoGpgKeyUrl: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

Advanced.defaultProps = {
  configParams: {},
  setupRemoteExecution: '',
  setupInsights: '',
  jwtExpiration: 4,
  packages: '',
  repo: '',
  repoGpgKeyUrl: '',
};

export default Advanced;
