import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './SubmitCancelButtonsActions';
import reducer from './SubmitCancelButtonsReducers';
import SubmitCancelButtons from './SubmitCancelButtons';

const mapStateToProps = ({ submitCancelButtons }) => ({
  submitting: submitCancelButtons.submitting,
  disabled: submitCancelButtons.disabled,
  replacer: window.location,
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { submitCancelButtons: reducer };
export default connect(mapStateToProps, mapDispatchToProps)(SubmitCancelButtons);
