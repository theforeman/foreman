import React from 'react';
import PropTypes from 'prop-types';

import { OverlayTrigger, Tooltip, Icon, MessageDialog } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';

import './ImpersonateIcon.scss';

class ImpersonateIcon extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      showModal: false,
    };
  }

  toggleModal = () => this.setState({ showModal: !this.state.showModal });

  stopImpersonating = url => () => {
    const stopUrl = `${window.location.origin}/${url}`;
    window.location.href = stopUrl;
  };

  render() {
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
            <span className="nav-item-iconic" onClick={this.toggleModal}>
              <Icon name="eye avatar small" className="blink-image" />
            </span>
          </li>
        </OverlayTrigger>
        <MessageDialog
          show={this.state.showModal}
          onHide={this.toggleModal}
          primaryAction={this.stopImpersonating(
            this.props.stopImpersonationUrl
          )}
          secondaryAction={this.toggleModal}
          primaryActionButtonContent={__('Confirm')}
          secondaryActionButtonContent={__('Cancel')}
          title={__('Confirm Action')}
          primaryContent={__(
            'You are about to stop impersonating other user. Are you sure?'
          )}
        />
      </React.Fragment>
    );
  }
}

ImpersonateIcon.propTypes = {
  stopImpersonationUrl: PropTypes.string.isRequired,
};

export default ImpersonateIcon;
