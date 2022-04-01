import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { EyeIcon } from '@patternfly/react-icons';
import { MessageDialog } from 'patternfly-react';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';
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
      <MessageDialog
        show={showModal}
        onHide={toggleModal}
        primaryAction={() =>
          props.stopImpersonating(props.stopImpersonationUrl)
        }
        secondaryAction={toggleModal}
        primaryActionButtonContent={__('Confirm')}
        secondaryActionButtonContent={__('Cancel')}
        title={__('Confirm Action')}
        primaryContent={__(
          'You are about to stop impersonating other user. Are you sure?'
        )}
      />
    </React.Fragment>
  );
};

ImpersonateIcon.propTypes = {
  stopImpersonationUrl: PropTypes.string.isRequired,
  stopImpersonating: PropTypes.func.isRequired,
};

export default ImpersonateIcon;
