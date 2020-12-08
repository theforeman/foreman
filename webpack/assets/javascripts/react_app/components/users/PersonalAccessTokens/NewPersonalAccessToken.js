import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';
import ClipboardCopy from '../../common/ClipboardCopy';
import { translate as __ } from '../../../common/I18n';

const NewTokenInfo = ({ newPersonalAccessToken, onDismiss }) => (
  <Fragment>
    {newPersonalAccessToken && (
      <Alert type="success" onDismiss={onDismiss}>
        <strong>{__('Your New Personal Access Token')}</strong>
        <ClipboardCopy
          text={newPersonalAccessToken}
          textareaProps={{ readOnly: true, className: 'col-md-6', rows: '1' }}
        />
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
