import { bindActionCreators } from '@theforeman/vendor/redux';
import { connect } from '@theforeman/vendor/react-redux';

import * as actions from './DiffModalActions';
import reducer from './DiffModalReducer';

import DiffModal from './DiffModal';

// map state to props
const mapStateToProps = ({ diffModal }) => ({
  isOpen: diffModal.isOpen,
  diff: diffModal.diff,
  title: diffModal.title,
  diffViewType: diffModal.diffViewType,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { diffModal: reducer };

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DiffModal);
