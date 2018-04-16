import React from 'react';
import Button from '../../common/forms/Button';
import { simpleLoader } from '../Loader';

export default ({
  onCancel,
  onSubmitClick,
  disabled = false,
  submitting = false,
}) => (
  <div className="clearfix">
    <div className="form-actions">
      <Button
        className="btn-primary"
        type="submit"
        onClick={onSubmitClick}
        disabled={disabled || submitting}>
        &nbsp;
        {__('Submit')}
        {submitting && <span className="fr">{simpleLoader('sm')}</span>}
      </Button>
      {' ' /* adds whitespace between the buttons */}
      <Button className="btn-default" disabled={disabled} onClick={onCancel}>
        {__('Cancel')}
      </Button>
    </div>
  </div>
);
