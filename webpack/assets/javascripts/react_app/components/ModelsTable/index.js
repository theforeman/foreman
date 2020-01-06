import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import ModelsTable from './ModelsTable';
import reducer from './ModelsTableReducer';
import * as actions from './ModelsTableActions';

const mapStateToProps = state => state.models_table;
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { models_table: reducer };

export default connect(mapStateToProps, mapDispatchToProps)(ModelsTable);
