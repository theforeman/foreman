import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './HostChartActions';
import reducer from './HostChartReducer';
import HostChart from './HostChart';

const mapStateToProps = ({ hostChart }) => ({ ...hostChart });
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { hostChart: reducer };
export default connect(mapStateToProps, mapDispatchToProps)(HostChart);
