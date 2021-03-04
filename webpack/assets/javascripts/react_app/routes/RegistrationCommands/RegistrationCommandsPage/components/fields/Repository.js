import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, TextInput } from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

const Repository = ({
  repo,
  handleRepo,
  repoGpg,
  handleRepoGpg,
  isLoading,
}) => (
  <>
    <FormGroup
      label={__('Repository')}
      fieldId="reg_smart_proxy"
      labelIcon={
        <LabelIcon
          text={__(
            "A repository to be added before the registration is performed. It can be useful to e.g. make the subscription-manager packages available for the purpose of the registration. For Red Hat family distributions, this should be the URL of the repository, e.g. 'http://rpm.example.com/'. For Debian OS families, it's the whole list file content, e.g. 'deb http://deb.example.com/ buster 1.0'."
          )}
        />
      }
    >
      <TextInput
        id="reg_repository"
        value={repo}
        type="text"
        onChange={handleRepo}
        isDisabled={isLoading}
      />
    </FormGroup>
    <FormGroup
      label={__('Repository GPG key')}
      fieldId="reg_smart_proxy"
      labelIcon={
        <LabelIcon
          text={__(
            'If packages are GPG signed, the public key can be specified here to verify the packages signatures. It needs to be specified in the ascii form with the pgp public key header.'
          )}
        />
      }
    >
      <TextInput
        id="reg_repository_gpg"
        value={repoGpg}
        type="text"
        onChange={handleRepoGpg}
        isDisabled={isLoading}
      />
    </FormGroup>
  </>
);

Repository.propTypes = {
  repo: PropTypes.string,
  repoGpg: PropTypes.string,
  handleRepo: PropTypes.func.isRequired,
  handleRepoGpg: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

Repository.defaultProps = {
  repo: '',
  repoGpg: '',
};

export default Repository;
