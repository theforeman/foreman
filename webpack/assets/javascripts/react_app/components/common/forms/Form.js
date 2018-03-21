import React from 'react';
import { Alert } from 'patternfly-react';

import AlertBody from '../Alert/AlertBody';
import Actions from './Actions';
import { translate as __ } from '../../../../react_app/common/I18n';

export default ({
  className = 'form-horizontal well',
  onSubmit,
  onCancel,
  children,
  error = false,
  touched,
  disabled = false,
  submitting = false,
  errorTitle = __('Unable to save'),
}) => (
  <form className={className} onSubmit={onSubmit}>
    {error && (
      <Alert className="base in fade" type="danger">
        <AlertBody title={errorTitle}>{error.map((e, idx) => <li key={idx}>{e}</li>)}</AlertBody>
      </Alert>
    )}
    {children}
    <Actions onCancel={onCancel} disabled={disabled} submitting={submitting} />
  </form>
);
