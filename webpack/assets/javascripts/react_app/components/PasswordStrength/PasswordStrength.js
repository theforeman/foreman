import React from 'react';
import PropTypes from 'prop-types';
import ReactPasswordStrength from 'react-password-strength';

import CommonForm from '../common/forms/CommonForm';

import './PasswordStrength.scss';

export default class PasswordStrength extends React.Component {
  render() {
    const {
      updatePassword,
      updatePasswordConfirmation,
      doesPasswordsMatch,
      data: { className, id, name, verify, error, userInputIds },
    } = this.props;

    const userInputs =
      userInputIds && userInputIds.length > 0
        ? userInputIds.map(input => document.getElementById(input).value)
        : [];

    return (
      <div>
        <CommonForm label={__('Password')} touched={true} error={error}>
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
            inputProps={{ name, id, className }}
          />
        </CommonForm>
        {verify && (
          <CommonForm
            label={__('Verify')}
            touched={true}
            error={
              doesPasswordsMatch ? verify.error : __('Passwords do not match')
            }
          >
            <input
              id="password_confirmation"
              name={verify.name}
              type="password"
              onChange={({ target }) =>
                updatePasswordConfirmation(target.value)
              }
              className="form-control"
            />
          </CommonForm>
        )}
      </div>
    );
  }
}

PasswordStrength.propTypes = {
  updatePassword: PropTypes.func.isRequired,
  updatePasswordConfirmation: PropTypes.func,
  doesPasswordsMatch: PropTypes.bool,
  data: PropTypes.shape({
    className: PropTypes.string,
    id: PropTypes.string,
    name: PropTypes.string,
    error: PropTypes.node,
    userInputIds: PropTypes.arrayOf(PropTypes.string),
    verify: PropTypes.shape({
      name: PropTypes.string.isRequired,
      error: PropTypes.node,
    }),
  }).isRequired,
};
