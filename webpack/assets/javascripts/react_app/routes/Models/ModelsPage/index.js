import React from 'react';
import { connect } from 'react-redux';
import { compose, bindActionCreators } from 'redux';

import ModelsPage from './ModelsPage';
import * as actions from './ModelsPageActions';

import { callOnMount, callOnPopState } from '../../../common/HOC';

import { useForemanContext } from '../../../Root/Context/ForemanContext';

import {
  selectModels,
  selectPage,
  selectPerPage,
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
  page: selectPage(state),
  perPage: selectPerPage(state),
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

const callWithToastsContext = Component => props => {
  const { toasts } = useForemanContext();
  return <Component {...props} toasts={toasts} />;
};

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  callWithToastsContext,
  callOnMount(({ initializeModels }) => initializeModels()),
  callOnPopState(({ initializeModels }) => initializeModels())
)(ModelsPage);
