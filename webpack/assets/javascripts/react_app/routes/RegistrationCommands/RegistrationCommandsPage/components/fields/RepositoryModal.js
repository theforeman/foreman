import React, { useState, useEffect } from 'react';

import PropTypes from 'prop-types';

import {
  FormGroup,
  Button,
  Modal,
  ModalVariant,
  Grid,
  GridItem,
} from '@patternfly/react-core';
import { PlusCircleIcon, MinusCircleIcon } from '@patternfly/react-icons';
import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

import RepositoryModalInput from './RepositoryModalInput';

const RepositoryModal = ({
  repoData,
  handleRepoData,
  isLoading,
  isModalOpen,
  handleModalToggle,
}) => {
  const initialRepoState = [
    {
      reference: 0,
      repository: '',
      gpgKeyUrl: '',
    },
  ];

  useEffect(() => {
    if (!repoData.length) {
      handleRepoData(initialRepoState);
    }
  }, [repoData, initialRepoState, handleRepoData]);

  const [repoReferenceCounter, setRepoReferenceCounter] = useState(0);

  const updateInput = (reference, input, inputType) => {
    handleRepoData(current =>
      current.map(repo => {
        if (repo.reference === reference) {
          if (inputType === 'repository') {
            return { ...repo, repository: input };
          }

          return { ...repo, gpgKeyUrl: input };
        }
        return repo;
      })
    );
  };

  const removeRepository = reference => {
    handleRepoData(current =>
      current.filter(repo => repo.reference !== reference)
    );
  };

  const addRepositoryModalInput = () => {
    const newRepoReferenceCounter = repoReferenceCounter + 1;
    handleRepoData(current => [
      ...current,
      {
        reference: newRepoReferenceCounter,
        repository: '',
        gpgKeyUrl: '',
      },
    ]);
    setRepoReferenceCounter(newRepoReferenceCounter);
  };

  const removeEmptyRows = () => {
    handleRepoData(current =>
      current.filter(repo => repo.repository !== '' || repo.gpgKeyUrl !== '')
    );
  };

  const clearRepositories = () => {
    handleRepoData(initialRepoState);
  };

  const renderRepo = repo => (
    <React.Fragment key={repo.reference}>
      <RepositoryModalInput
        reference={repo.reference}
        updateRepository={updateInput}
        isLoading={isLoading}
        initRepo={repo.repository}
        initGpgKey={repo.gpgKeyUrl}
      />
      <GridItem span={2}>
        <Button
          ouiaId={repo.reference}
          variant="link"
          icon=<MinusCircleIcon />
          onClick={() => removeRepository(repo.reference)}
        >
          {__('Remove')}
        </Button>
      </GridItem>
    </React.Fragment>
  );

  const handleConfirm = () => {
    removeEmptyRows();
    handleModalToggle();
  };

  return (
    <Modal
      variant={ModalVariant.medium}
      ouiaId="host_reg_repo_modal"
      title={__('Repository list')}
      isOpen={isModalOpen}
      onClose={handleConfirm}
      actions={[
        <Button
          ouiaId="reg_modal_confirm"
          variant="primary"
          onClick={handleConfirm}
        >
          {__('Confirm')}
        </Button>,
        <Button
          ouiaId="reg_modal_reset"
          variant="link"
          onClick={clearRepositories}
        >
          {__('Reset form')}
        </Button>,
        <Button
          ouiaId="host_reg_modal_add_new_repo"
          variant="link"
          icon={<PlusCircleIcon />}
          onClick={addRepositoryModalInput}
        >
          {__('Add repository')}
        </Button>,
      ]}
    >
      <Grid hasGutter>
        <GridItem span={5}>
          <FormGroup
            label={__('Repository')}
            fieldId="reg_repo"
            labelIcon={
              <LabelIcon
                text={__(
                  "A repository to be added before the registration is performed. For Red Hat and SUSE family distributions, this should be the URL of the repository, e.g. 'http://rpm.example.com/'. For Debian OS families, it's the whole list file content, e.g. 'deb http://deb.example.com/ buster 1.0'."
                )}
              />
            }
          />
        </GridItem>
        <GridItem span={5}>
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
          />
        </GridItem>
        <GridItem span={2} />
        {repoData.map(r => renderRepo(r))}
      </Grid>
    </Modal>
  );
};

RepositoryModal.propTypes = {
  repoData: PropTypes.array.isRequired,
  handleRepoData: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isModalOpen: PropTypes.bool.isRequired,
  handleModalToggle: PropTypes.func.isRequired,
};

export default RepositoryModal;
