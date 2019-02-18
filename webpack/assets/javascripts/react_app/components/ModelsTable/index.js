import { connect } from '@theforeman/vendor/react-redux';
import { bindActionCreators } from '@theforeman/vendor/redux';
import ModelsTable from './ModelsTable';
import reducer from './ModelsTableReducer';
import * as actions from '../common/table/actions/getTableItemsAction';

const mapStateToProps = state => state.models;
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { models: reducer };

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ModelsTable);
