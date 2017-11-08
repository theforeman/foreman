import React from 'react';
import Actions from './Actions';
import Alert from '../Alert';

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
      <Alert className="base in fade" type="danger" title={errorTitle}>
        {error.map((e, idx) => <li key={idx}>{e}</li>)}
      </Alert>
    )}
    {children}
    <Actions onCancel={onCancel} disabled={disabled} submitting={submitting} />
  </form>
);
