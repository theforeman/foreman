import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';

import { noop } from '../../../common/helpers';
import AlertBody from '../Alert/AlertBody';
import Actions from './Actions';
import { translate as __ } from '../../../../react_app/common/I18n';

const Form = ({
  className,
  onSubmit,
  onCancel,
  children,
  error,
  touched,
  disabled,
  submitting,
  errorTitle,
}) => (
  <form className={className} onSubmit={onSubmit}>
    {error && (
      <Alert className="base in fade" type={error.severity || 'danger'}>
        <AlertBody title={errorTitle}>
          {error.errorMsgs.length === 1 ? (
            <span>{error.errorMsgs[0]}</span>
          ) : (
            error.errorMsgs.map((e, idx) => <li key={idx}>{e}</li>)
          )}
        </AlertBody>
      </Alert>
    )}
    {children}
    <Actions onCancel={onCancel} disabled={disabled} submitting={submitting} />
  </form>
);

Form.propTypes = {
  children: PropTypes.node,
  className: PropTypes.string,
  error: PropTypes.shape({
    errorMsgs: PropTypes.arrayOf(PropTypes.string),
    severity: PropTypes.string,
  }),
  touched: PropTypes.bool,
  disabled: PropTypes.bool,
  submitting: PropTypes.bool,
  errorTitle: PropTypes.string,
  onSubmit: PropTypes.func,
  onCancel: PropTypes.func,
};

Form.defaultProps = {
  className: 'form-horizontal well',
  children: null,
  error: null,
  touched: false,
  disabled: false,
  submitting: false,
  errorTitle: `${__('Unable to save')}. `,
  onSubmit: noop,
  onCancel: noop,
};

export default Form;
