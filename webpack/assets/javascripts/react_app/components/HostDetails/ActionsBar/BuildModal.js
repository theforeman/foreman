import PropTypes from 'prop-types';
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  Modal,
  ModalVariant,
  Button,
  Alert,
  Stack,
  StackItem,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from '../../../common/I18n';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import { foremanUrl } from '../../../common/helpers';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';
import { API_OPTIONS, SUPPORTED_ERRORS } from './constants';
import { selectBuildErrorsTree, selectNoErrorState } from './Selectors';
import { buildHost } from './actions';
import StatusIcon from '../Status/StatusIcon';
import { ERROR_STATUS_STATE, OK_STATUS_STATE } from '../Status/Constants';
import { ErrorsTree } from './ErrorsTree/ErrorsTree';

const BuildModal = ({ isModalOpen, onClose, hostFriendlyId, hostName }) => {
  const errorsTree = useSelector(selectBuildErrorsTree);
  const noErrors = useSelector(selectNoErrorState);
  const dispach = useDispatch();
  const { status } = useAPI(
    'get',
    foremanUrl(`/hosts/${hostFriendlyId}/review_before_build`),
    API_OPTIONS
  );

  return (
    <Modal
      ouiaId="review-build-modal"
      variant={ModalVariant.medium}
      title={__('Review before build')}
      isOpen={isModalOpen}
      onClose={onClose}
      actions={[
        <Button
          ouiaId="confirm-button"
          key="confirm"
          variant="primary"
          onClick={() => {
            dispach(buildHost(hostFriendlyId));
            onClose();
          }}
        >
          {__('Build')}
        </Button>,
        <Button
          ouiaId="cancel-button"
          key="cancel"
          variant="link"
          onClick={onClose}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <Stack hasGutter>
        <StackItem>
          <FormattedMessage
            id="build"
            values={{
              hostName: <b>{hostName}</b>,
            }}
            defaultMessage={__(
              'Build enables host {hostName} to rebuild on next boot'
            )}
          />
        </StackItem>

        <StackItem>
          <Alert
            ouiaId="warning-alert"
            variant="warning"
            isInline
            title={__(
              'This action will delete this host and all its data (i.e facts, report)'
            )}
          />
        </StackItem>
        <StackItem>
          <SkeletonLoader
            skeletonProps={{ count: Object.keys(SUPPORTED_ERRORS).length }}
            status={status || STATUS.PENDING}
          >
            {noErrors ? (
              <StatusIcon
                label={__('No errors detected')}
                statusNumber={OK_STATUS_STATE}
              />
            ) : (
              <>
                <StatusIcon
                  label={__(
                    'The following errors may prevent a successful build:'
                  )}
                  statusNumber={ERROR_STATUS_STATE}
                />

                <ErrorsTree data={errorsTree} />
              </>
            )}
          </SkeletonLoader>
        </StackItem>
      </Stack>
    </Modal>
  );
};

BuildModal.propTypes = {
  hostFriendlyId: PropTypes.string.isRequired,
  hostName: PropTypes.string.isRequired,
  isModalOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default BuildModal;
