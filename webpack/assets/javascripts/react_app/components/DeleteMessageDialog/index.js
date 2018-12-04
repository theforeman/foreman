import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from './DeleteMessageDialogActions';
import DeleteConfirmationDialog from './DeleteConfirmationDialog';
import reducer from './DeleteMessageDialogReducer';

const mapStateToProps = state => ({
  show: state.deleteDialog.show,
  processing: state.deleteDialog.processing,
  name: state.deleteDialog.name,
  url: state.deleteDialog.url,
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { deleteDialog: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DeleteConfirmationDialog);
