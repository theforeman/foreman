import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import ReportTemplatesTable from './ReportTemplatesTable';
import reducer from './ReportTemplatesTableReducer';
import * as actions from './ReportTemplatesTableActions';

const mapStateToProps = state => state.report_templates_table;
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { report_templates_table: reducer };

export default connect(mapStateToProps, mapDispatchToProps)(ReportTemplatesTable);
