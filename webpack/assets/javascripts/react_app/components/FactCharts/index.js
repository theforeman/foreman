import { connect } from 'react-redux';
import {
  selectHostCount,
  selectDisplayModal,
  selectFactChartStatus,
  selectFactChartData,
} from './FactChartSelectors';

import * as actions from './FactChartActions';
import reducer from './FactChartReducer';

import FactChart from './FactChart';

const mapStateToProps = (state, ownProps) => ({
  hostsCount: selectHostCount(state),
  modalToDisplay: selectDisplayModal(state, ownProps.data.id),
  status: selectFactChartStatus(state),
  chartData: selectFactChartData(state),
});

// export reducers
export const reducers = { factChart: reducer };

export default connect(mapStateToProps, actions)(FactChart);
