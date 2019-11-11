import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './PasswordStrengthActions';
import {
  doesPasswordsMatch,
  passwordPresent,
} from './PasswordStrengthSelectors';
import reducer from './PasswordStrengthReducer';

import PasswordStrength from './PasswordStrength';

// map state to props
const mapStateToProps = ({ passwordStrength }) => ({
  doesPasswordsMatch: doesPasswordsMatch(passwordStrength),
  passwordPresent: passwordPresent(passwordStrength),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { passwordStrength: reducer };

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(PasswordStrength);
