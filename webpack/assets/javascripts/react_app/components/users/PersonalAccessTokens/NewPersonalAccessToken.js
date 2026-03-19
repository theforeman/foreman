import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import {
  ClipboardCopy,
  Alert,
  AlertGroup,
  AlertActionCloseButton,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import './personalAccessToken.scss';

const NewTokenInfo = ({ newPersonalAccessToken, onDismiss }) => (
  <Fragment>
    {newPersonalAccessToken && (
      <AlertGroup>
        <Alert
          variant="success"
          ouiaId="new-token-info-alert"
          actionClose={<AlertActionCloseButton onClose={onDismiss} />}
          title={__('Your New Personal Access Token')}
        >
          <ClipboardCopy
            isReadOnly
            hoverTip={__('Copy to clipboard')}
            clickTip={__('Copied to clipboard')}
            variant="inline-compact"
            id="personal-token-clipboard"
          >
            {newPersonalAccessToken}
          </ClipboardCopy>
          {__(
            'Make sure to copy your new personal access token now. You won’t be able to see it again!'
          )}
        </Alert>
      </AlertGroup>
    )}
  </Fragment>
);

NewTokenInfo.propTypes = {
  onDismiss: PropTypes.func.isRequired,
  newPersonalAccessToken: PropTypes.string,
};

NewTokenInfo.defaultProps = {
  newPersonalAccessToken: null,
};

export default NewTokenInfo;
