import React from 'react';

import PropTypes from 'prop-types';

import { FormGroup, TextInput, GridItem } from '@patternfly/react-core';

const RepositoryModalInput = ({
  reference,
  updateRepository,
  isLoading,
  initRepo,
  initGpgKey,
}) => {
  const onRepoUpdate = repo => {
    updateRepository(reference, repo, 'repository');
  };

  const onGpgKeyUpdate = gpgKey => {
    updateRepository(reference, gpgKey, 'gpgKeyUrl');
  };

  return (
    <>
      <GridItem span={5}>
        <FormGroup fieldId="host_reg_repo">
          <TextInput
            ouiaId="host_reg_repo"
            id="host_reg_repo"
            value={initRepo}
            type="text"
            onChange={(_event, repo) => onRepoUpdate(repo)}
            isDisabled={isLoading}
          />
        </FormGroup>
      </GridItem>
      <GridItem span={5}>
        <FormGroup fieldId="reg_gpg_key_url">
          <TextInput
            ouiaId="host_reg_gpg_key"
            id="host_reg_gpg_key"
            value={initGpgKey}
            type="text"
            onChange={(_event, gpgKey) => onGpgKeyUpdate(gpgKey)}
            isDisabled={isLoading}
          />
        </FormGroup>
      </GridItem>
    </>
  );
};

RepositoryModalInput.propTypes = {
  reference: PropTypes.number.isRequired,
  updateRepository: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  initRepo: PropTypes.string.isRequired,
  initGpgKey: PropTypes.string.isRequired,
};

export default RepositoryModalInput;
