import { connect } from 'react-redux';
import {
  selectHostCount,
  selectFactChart,
  selectDisplayModal,
} from './FactChartSelectors';

import * as actions from './FactChartActions';
import reducer from './FactChartReducer';

import FactChart from './FactChart';

const mapStateToProps = (state, ownProps) => ({
  factChart: selectFactChart(state),
  hostsCount: selectHostCount(state),
  modalToDisplay: selectDisplayModal(state, ownProps.data.id),
});

// export reducers
export const reducers = { factChart: reducer };

export default connect(mapStateToProps, actions)(FactChart);
