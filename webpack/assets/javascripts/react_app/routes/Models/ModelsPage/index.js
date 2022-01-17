import { connect } from 'react-redux';
import { compose, bindActionCreators } from 'redux';

import ModelsPage from './ModelsPage';
import * as actions from './ModelsPageActions';

import { callOnMount, callOnPopState } from '../../../common/HOC';

import {
  selectModels,
  selectSearch,
  selectSort,
  selectHasData,
  selectHasError,
  selectIsLoading,
  selectSubtotal,
  selectMessage,
  selectCanCreate,
} from './ModelsPageSelectors';

const mapStateToProps = state => ({
  models: selectModels(state),
  search: selectSearch(state),
  sort: selectSort(state),
  isLoading: selectIsLoading(state),
  hasData: selectHasData(state),
  hasError: selectHasError(state),
  itemCount: selectSubtotal(state),
  message: selectMessage(state),
  canCreate: selectCanCreate(state),
});

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callOnMount(({ initializeModels }) => initializeModels()),
  callOnPopState(({ initializeModels }) => initializeModels())
)(ModelsPage);
