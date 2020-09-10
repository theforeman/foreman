import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { OverlayTrigger, Tooltip, Icon, MessageDialog } from 'patternfly-react';
import { translate as __ } from '../../../../common/I18n';

import './ImpersonateIcon.scss';

const ImpersonateIcon = props => {
  const [showModal, setShowModal] = useState(false);

  const toggleModal = () => setShowModal(!showModal);

  return (
    <React.Fragment>
      <OverlayTrigger
        overlay={
          <Tooltip id="stop-impersonation">
            {__(
              'You are impersonating another user, click to stop the impersonation'
            )}
          </Tooltip>
        }
        placement="bottom"
        trigger={['hover', 'focus']}
        rootClose={false}
      >
        <li className="drawer-pf-trigger masthead-icon">
          <span className="nav-item-iconic" onClick={toggleModal}>
            <Icon name="eye avatar small" className="blink-image" />
          </span>
        </li>
      </OverlayTrigger>
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
