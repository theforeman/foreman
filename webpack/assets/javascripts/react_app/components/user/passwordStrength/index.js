import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import CommonForm from '../../common/forms/CommonForm';
import {
  updatePassword,
  checkPasswordsMatch,
} from '../../../redux/actions/user/passwordStrength';
import helpers from '../../../common/helpers';
import './password_strength.scss';

class PasswordStrength extends React.Component {
  constructor(props) {
    super(props);
    helpers.bindMethods(this, ['checkRetype']);
  }
  checkRetype(event) {
    this.props.checkPasswordsMatch(event.target.value, this.props.password);
  }

  render() {
    const {
      data: {
        className, id, name, verify, error, userInputIds,
      },
      matchMessage,
    } = this.props;

    return (
      <div>
        <CommonForm label={__('Password')} touched={true} error={error}>
          <ReactPasswordStrength
            changeCallback={({ password }) => this.props.updatePassword(password)}
            minLength={6}
            minScore={2}
            userInputs={
              userInputIds.length > 0
                ? userInputIds.map(input => document.getElementById(input).value)
                : []
            }
            tooShortWord={__('Too short')}
            scoreWords={[
              __('Weak'),
              __('Medium'),
              __('Normal'),
              __('Strong'),
              __('Very strong'),
            ]}
            inputProps={{
              name,
              id,
              className,
            }}
          />
        </CommonForm>
        {verify && (
          <CommonForm
            label={__('Verify')}
            touched={true}
            error={matchMessage ? verify.error : __('Password do not match')}
          >
            <input
              id="password_confirmation"
              name={verify.name}
              type="password"
              onChange={this.checkRetype}
              className="form-control"
            />
          </CommonForm>
        )}
      </div>
    );
  }
}
const mapStateToProps = state => ({
  password: state.passwordStrength.password.value,
  matchMessage: state.passwordStrength.password.match,
});

const mapDispatchToProps = dispatch => bindActionCreators(
  {
    updatePassword,
    checkPasswordsMatch,
  },
  dispatch,
);

export default connect(mapStateToProps, mapDispatchToProps)(PasswordStrength);
