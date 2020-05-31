import { connect } from 'react-redux';
import { bindActionCreators, combineReducers } from 'redux';
import ModelsTable from './ModelsTable';
import reducer from './ModelsTableReducer';
import {
  selectAllRows,
  unselectAllRows,
  selectionReducer,
} from '../common/table';
import * as actions from './ModelsTableActions';
import { MODELS_TABLE_ID } from './ModelsTableConstants';

const mapStateToProps = state => ({
  ...state.models_table.data,
  ...state.models_table.selection,
});
const mapDispatchToProps = dispatch =>
  bindActionCreators({ ...actions, selectAllRows, unselectAllRows }, dispatch);

export const reducers = {
  models_table: combineReducers({
    data: reducer,
    selection: selectionReducer(MODELS_TABLE_ID),
  }),
};

export default connect(mapStateToProps, mapDispatchToProps)(ModelsTable);
