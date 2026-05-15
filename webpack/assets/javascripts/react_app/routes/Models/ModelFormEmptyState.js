import React from 'react';
import PropTypes from 'prop-types';
import { ResourceLoadFailedEmptyState } from '../../components/common/EmptyState';
import { translate as __ } from '../../common/I18n';
import { MODELS_PATH, MODELS_PATH_NEW } from './constants';

const ModelFormEmptyState = ({ modelId, errorMessage, httpStatus }) => (
  <ResourceLoadFailedEmptyState
    resourceLabel={__('hardware model')}
    resourceId={modelId}
    errorMessage={errorMessage}
    httpStatus={httpStatus}
    viewPermissions={['view_models']}
    requiredPermissions={['view_models', 'edit_models']}
    ouiaIdPrefix="model-form-empty-state"
    primaryAction={{
      label: __('Back to hardware models'),
      url: MODELS_PATH,
      ouiaId: 'model-form-empty-state-models-list',
    }}
    secondaryActions={[
      {
        label: __('Create a new hardware model'),
        url: MODELS_PATH_NEW,
        ouiaId: 'model-form-empty-state-create-model',
      },
    ]}
  />
);

ModelFormEmptyState.propTypes = {
  modelId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  errorMessage: PropTypes.string,
  httpStatus: PropTypes.number,
};

ModelFormEmptyState.defaultProps = {
  errorMessage: null,
  httpStatus: null,
};

export default ModelFormEmptyState;
