import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';
import { ClipboardCopy } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import './personalAccessToken.scss';

const NewTokenInfo = ({ newPersonalAccessToken, onDismiss }) => (
  <Fragment>
    {newPersonalAccessToken && (
      <Alert type="success" onDismiss={onDismiss}>
        <strong>{__('Your New Personal Access Token')}</strong>
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
