import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';

import { noop } from '../../../common/helpers';
import { simpleLoader } from '../Loader';
import { translate as __ } from '../../../../react_app/common/I18n';
import { deprecate } from '../../../common/DeprecationService';

const FormActions = ({ onCancel, disabled, submitting }) => {
  useEffect(() => {
    deprecate(
      'forms/Actions',
      'ActionGroup from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
    <div className="clearfix">
      <div className="form-actions">
        <Button
          bsStyle="primary"
          type="submit"
          disabled={disabled || submitting}
        >
          &nbsp;
          {__('Submit')}
          {submitting && <span className="fr">{simpleLoader('sm')}</span>}
        </Button>
        {' ' /* adds whitespace between the buttons */}
        <Button bsStyle="default" onClick={onCancel} disabled={submitting}>
          {__('Cancel')}
        </Button>
      </div>
    </div>
  );
};

FormActions.propTypes = {
  disabled: PropTypes.bool,
  submitting: PropTypes.bool,
  onCancel: PropTypes.func,
};

FormActions.defaultProps = {
  disabled: false,
  submitting: false,
  onCancel: noop,
};

export default FormActions;
