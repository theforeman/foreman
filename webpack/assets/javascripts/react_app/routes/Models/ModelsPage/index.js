import { connect } from 'react-redux';
import { compose, bindActionCreators } from 'redux';

import ModelsPage from './ModelsPage';
import * as actions from './ModelsPageActions';

import { callOnPopState } from '../../../common/HOC';

import {
  selectModels,
  selectSort,
  selectHasData,
  selectHasError,
  selectIsLoading,
  selectSubtotal,
  selectMessage,
} from './ModelsPageSelectors';

const mapStateToProps = state => ({
  models: selectModels(state),
  sort: selectSort(state),
  isLoading: selectIsLoading(state),
  hasData: selectHasData(state),
  hasError: selectHasError(state),
  itemCount: selectSubtotal(state),
  message: selectMessage(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callOnPopState(({ initializeModels }) => initializeModels())
)(ModelsPage);
