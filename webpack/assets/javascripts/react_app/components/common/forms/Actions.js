import React from 'react';
import { Button } from 'patternfly-react';
import { simpleLoader } from '../Loader';
import { translate as __ } from '../../../../react_app/common/I18n';

export default ({ onCancel, disabled = false, submitting = false }) => (
  <div className="clearfix">
    <div className="form-actions">
      <Button bsStyle="primary" type="submit" disabled={disabled || submitting}>
          &nbsp;
        {__('Submit')}
        {submitting &&
        <span className="fr">
          {simpleLoader('sm')}
        </span>}
      </Button>
      {' ' /* adds whitespace between the buttons */}
      <Button bsStyle="default" disabled={disabled} onClick={onCancel}>
        {__('Cancel')}
      </Button>
    </div>
  </div>
);
