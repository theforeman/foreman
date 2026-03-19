import React from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import { Button, EmptyStateVariant } from '@patternfly/react-core';
import { SearchIcon } from '@patternfly/react-icons';
import EmptyStatePattern from '../../components/common/EmptyState/EmptyStatePattern';
import { translate as __, sprintf } from '../../common/I18n';
import { MODELS_PATH, MODELS_PATH_NEW } from './constants';

const ModelFormEmptyState = ({ modelId, errorMessage }) => {
  const history = useHistory();

  const description = (
    <>
      <p>
        {sprintf(
          __(
            'The hardware model with id %s could not be loaded. It may not exist or you may not have permission to view it.'
          ),
          modelId
        )}
      </p>
      {errorMessage ? <p>{errorMessage}</p> : null}
    </>
  );

  return (
    <EmptyStatePattern
      variant={EmptyStateVariant.lg}
      icon={<SearchIcon />}
      header={__('Unable to load hardware model')}
      description={description}
      action={
        <Button
          ouiaId="model-form-empty-state-models-list"
          variant="primary"
          onClick={() => history.push(MODELS_PATH)}
        >
          {__('Back to hardware models')}
        </Button>
      }
      secondaryActions={
        <>
          <Button
            ouiaId="model-form-empty-state-create-model"
            variant="link"
            onClick={() => history.push(MODELS_PATH_NEW)}
          >
            {__('Create a new hardware model')}
          </Button>
          <Button
            ouiaId="model-form-empty-state-go-back"
            variant="link"
            onClick={() => history.goBack()}
          >
            {__('Return to the previous page')}
          </Button>
        </>
      }
    />
  );
};

ModelFormEmptyState.propTypes = {
  modelId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  errorMessage: PropTypes.string,
};

ModelFormEmptyState.defaultProps = {
  errorMessage: null,
};

export default ModelFormEmptyState;
