import React, { useState } from 'react';

import PropTypes from 'prop-types';

import { Button, FormGroup } from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { sprintf, translate as __ } from '../../../../../common/I18n';

import RepositoryModal from './RepositoryModal';

const Repository = ({ repoData, handleRepoData, isLoading }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleModalToggle = () => {
    setIsModalOpen(!isModalOpen);
  };

  const realRepoNumber = () => repoData.filter(r => r.repository !== '').length;

  return (
    <>
      <RepositoryModal
        ouiaId="register_host_repo_modal"
        id="register_host_repo_modal"
        repoData={repoData}
        handleRepoData={handleRepoData}
        isLoading={isLoading}
        isModalOpen={isModalOpen}
        handleModalToggle={handleModalToggle}
      />
      <FormGroup
        label={__('Repositories')}
        fieldId="reg_repo"
        labelIcon={
          <LabelIcon
            text={__(
              'Repositories to be added before the registration is performed. It can be useful to e.g. make the subscription-manager packages available for the purpose of the registration. GPG keys can also be provided here if necessary.'
            )}
          />
        }
      >
        <Button
          ouiaId="host_reg_add_more_repositories"
          variant="link"
          icon={<PlusCircleIcon />}
          onClick={handleModalToggle}
        >
          {sprintf(
            __('Add repositories for registration (%s set)'),
            realRepoNumber()
          )}
        </Button>
      </FormGroup>
    </>
  );
};

Repository.propTypes = {
  repoData: PropTypes.array.isRequired,
  handleRepoData: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

export default Repository;
