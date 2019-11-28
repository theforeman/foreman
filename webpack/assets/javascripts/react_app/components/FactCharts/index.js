import { connect } from 'react-redux';
import {
  selectHostCount,
  selectDisplayModal,
  selectFactChartAPI,
} from './FactChartSelectors';

import * as actions from './FactChartActions';
import reducer, { apiReducer } from './FactChartReducer';

import FactChart from './FactChart';

const mapStateToProps = (state, ownProps) => ({
  factChart: selectFactChartAPI(state),
  hostsCount: selectHostCount(state),
  modalToDisplay: selectDisplayModal(state, ownProps.data.id),
});

// export reducers
export const reducers = { factChart: reducer, factChartAPI: apiReducer };

export default connect(mapStateToProps, actions)(FactChart);
