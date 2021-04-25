import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, TextInput } from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

const Repository = ({
  repo,
  handleRepo,
  repoGpgKeyUrl,
  handleRepoGpgKeyUrl,
  isLoading,
}) => (
  <>
    <FormGroup
      label={__('Repository')}
      fieldId="reg_repo"
      labelIcon={
        <LabelIcon
          text={__(
            "A repository to be added before the registration is performed. It can be useful to e.g. make the subscription-manager packages available for the purpose of the registration. For Red Hat family distributions, this should be the URL of the repository, e.g. 'http://rpm.example.com/'. For Debian OS families, it's the whole list file content, e.g. 'deb http://deb.example.com/ buster 1.0'."
          )}
        />
      }
    >
      <TextInput
        id="reg_repo"
        value={repo}
        type="text"
        onChange={handleRepo}
        isDisabled={isLoading}
      />
    </FormGroup>
    <FormGroup
      label={__('Repository GPG key URL')}
      fieldId="reg_gpg_key_url"
      labelIcon={
        <LabelIcon
          text={__(
            'If packages are GPG signed, the public key can be specified here to verify the packages signatures. It needs to be specified in the ascii form with the GPG public key header.'
          )}
        />
      }
    >
      <TextInput
        id="reg_gpg_key_url"
        value={repoGpgKeyUrl}
        type="text"
        onChange={handleRepoGpgKeyUrl}
        isDisabled={isLoading}
      />
    </FormGroup>
  </>
);

Repository.propTypes = {
  repo: PropTypes.string,
  repoGpgKeyUrl: PropTypes.string,
  handleRepo: PropTypes.func.isRequired,
  handleRepoGpgKeyUrl: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

Repository.defaultProps = {
  repo: '',
  repoGpgKeyUrl: '',
};

export default Repository;
