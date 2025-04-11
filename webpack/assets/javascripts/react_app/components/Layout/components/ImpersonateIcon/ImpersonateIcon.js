import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { EyeIcon } from '@patternfly/react-icons';
import {
  Tooltip,
  TooltipPosition,
  Modal,
  ModalVariant,
  Button,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../common/I18n';

import './ImpersonateIcon.scss';

const ImpersonateIcon = props => {
  const [showModal, setShowModal] = useState(false);

  const toggleModal = () => setShowModal(!showModal);

  return (
    <React.Fragment>
      <Tooltip
        content={__(
          'You are impersonating another user, click to stop the impersonation'
        )}
        position={TooltipPosition.bottom}
      >
        <span className="nav-item-iconic" onClick={toggleModal}>
          <EyeIcon className="blink-image" />
        </span>
      </Tooltip>
      <Modal
        ouiaId="impersonate-modal"
        variant={ModalVariant.small}
        position="top"
        isOpen={showModal}
        onClose={toggleModal}
        title={__('Confirm Action')}
        actions={[
          <Button
            ouiaId="stop-impersonating"
            key="confirm"
            variant="primary"
            onClick={() => props.stopImpersonating(props.stopImpersonationUrl)}
          >
            {__('Confirm')}
          </Button>,
          <Button
            ouiaId="cancel-impersonating-modal"
            key="cancel"
            variant="secondary"
            onClick={toggleModal}
          >
            {__('Cancel')}
          </Button>,
        ]}
      >
        {__('You are about to stop impersonating other user. Are you sure?')}
      </Modal>
    </React.Fragment>
  );
};

ImpersonateIcon.propTypes = {
  stopImpersonationUrl: PropTypes.string.isRequired,
  stopImpersonating: PropTypes.func.isRequired,
};

export default ImpersonateIcon;
