import React from 'react';
import PropTypes from 'prop-types';
import ReactPasswordStrength from 'react-password-strength';
import { translate as __ } from '../../../react_app/common/I18n';
import { noop } from '../../common/helpers';

import HorizontalFormField from './HorizontalFormField';
import './PasswordStrength.scss';

const PasswordStrength = ({
  updatePassword,
  updatePasswordConfirmation,
  doesPasswordsMatch,
  passwordPresent,
  data: { className, id, name, verify, error, userInputIds, required },
}) => {
  const userInputs =
    userInputIds && userInputIds.length > 0
      ? userInputIds.map(input => document.getElementById(input).value)
      : [];

  const passwordError = !passwordPresent && error;
  let verifyError = null;

  if (verify) {
    if (doesPasswordsMatch) {
      verifyError = verify.error;
    } else {
      verifyError = __('Passwords do not match');
    }
  }

  return (
    <div>
      <HorizontalFormField
        label={__('Password')}
        required={required}
        touched
        error={passwordError}
      >
        <ReactPasswordStrength
          changeCallback={({ password }) => updatePassword(password)}
          minLength={6}
          minScore={2}
          userInputs={userInputs}
          tooShortWord={__('Too short')}
          scoreWords={[
            __('Weak'),
            __('Medium'),
            __('Normal'),
            __('Strong'),
            __('Very strong'),
          ]}
          inputProps={{ name, id, className, autoComplete: 'new-password' }}
        />
      </HorizontalFormField>
      {verify && (
        <HorizontalFormField
          label={__('Verify')}
          required={required}
          touched
          error={verifyError || undefined}
        >
          <input
            id="password_confirmation"
            name={verify.name}
            type="password"
            onChange={({ target }) => updatePasswordConfirmation(target.value)}
            className="form-control"
          />
        </HorizontalFormField>
      )}
    </div>
  );
};

PasswordStrength.propTypes = {
  updatePassword: PropTypes.func,
  updatePasswordConfirmation: PropTypes.func,
  doesPasswordsMatch: PropTypes.bool,
  passwordPresent: PropTypes.bool,
  data: PropTypes.shape({
    className: PropTypes.string,
    id: PropTypes.string,
    name: PropTypes.string,
    error: PropTypes.node,
    userInputIds: PropTypes.arrayOf(PropTypes.string),
    required: PropTypes.bool,
    verify: PropTypes.shape({
      name: PropTypes.string.isRequired,
      error: PropTypes.node,
    }),
  }).isRequired,
};

PasswordStrength.defaultProps = {
  updatePassword: noop,
  updatePasswordConfirmation: noop,
  doesPasswordsMatch: false,
  passwordPresent: false,
};

export default PasswordStrength;
