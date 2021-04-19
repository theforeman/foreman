import React from 'react';
import PropTypes from 'prop-types';

import {
  Alert,
  Button,
  Grid,
  GridItem,
  Modal,
  ModalVariant,
} from '@patternfly/react-core';

import { translate as __ } from '../../common/I18n';
import { STATUS } from '../../constants';

const InvalidateUserJwt = ({
  isModalOpen,
  handleModal,
  handleSubmit,
  apiStatus,
  isLoading,
}) => (
  <>
    <Grid hasGutter>
      <GridItem span={12}>
        <Button
          onClick={() => handleModal(true)}
          variant="danger"
          isLoading={isLoading}
        >
          {isLoading ? __('Invalidating ...') : __('Invalidate JWTs')}
        </Button>
      </GridItem>
      <Modal
        variant={ModalVariant.small}
        title={__('Invalidate JSON web tokens')}
        isOpen={isModalOpen}
        onClose={() => handleModal(false)}
        actions={[
          <Button
            key="confirm"
            variant="primary"
            onClick={() => handleSubmit()}
          >
            {__('Confirm')}
          </Button>,
          <Button
            key="cancel"
            variant="link"
            onClick={() => handleModal(false)}
          >
            {__('Cancel')}
          </Button>,
        ]}
      />
      {apiStatus === STATUS.ERROR && (
        <GridItem span={8}>
          <Alert
            variant="danger"
            title={__(
              'JSON web tokens could not be invalidated, please see the log for more details'
            )}
          />
        </GridItem>
      )}
      {apiStatus === STATUS.RESOLVED && (
        <GridItem span={8}>
          <Alert
            variant="success"
            title={__('JSON web tokens successfully invalidated')}
          />
        </GridItem>
      )}
    </Grid>
  </>
);

InvalidateUserJwt.propTypes = {
  isModalOpen: PropTypes.bool.isRequired,
  handleModal: PropTypes.func.isRequired,
  handleSubmit: PropTypes.func.isRequired,
  apiStatus: PropTypes.string,
  isLoading: PropTypes.bool.isRequired,
};

InvalidateUserJwt.defaultProps = {
  apiStatus: '',
};

export default InvalidateUserJwt;
