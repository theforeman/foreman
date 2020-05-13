import { compose, bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { callOnMount } from '../../../common/HOC';

import * as actions from './StatisticsPageActions';
import withDataReducer from '../../common/reducerHOC/withDataReducer';
import {
  selectStatisticsMetadata,
  selectStatisticsDiscussionUrl,
  selectStatisticsMessage,
  selectStatisticsIsLoading,
  selectStatisticsHasMetadata,
  selectStatisticsHasError,
} from './StatisticsPageSelectors';

import StatisticsPage from './StatisticsPage';

// map state to props
const mapStateToProps = state => ({
  statisticsMeta: selectStatisticsMetadata(state),
  discussionUrl: selectStatisticsDiscussionUrl(state),
  isLoading: selectStatisticsIsLoading(state),
  message: selectStatisticsMessage(state),
  hasData: selectStatisticsHasMetadata(state),
  hasError: selectStatisticsHasError(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { statisticsPage: withDataReducer('STATISTICS_PAGE') };

// export connected component
export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callOnMount(({ getStatisticsMeta }) => getStatisticsMeta())
)(StatisticsPage);
