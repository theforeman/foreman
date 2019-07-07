import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from './DualListActions';
import reducer from './DualListReducer';
import DualList from './DualList';

const mapStateToProps = (state, { id }) => ({});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { dualList: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DualList);
