import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './BreadcrumbBarActions';
import reducer from './BreadcrumbBarReducer';

import {
  selectResourceSwitcherItems,
  selectIsSwitcherOpen,
  selectResourceUrl,
  selectIsLoadingResources,
  selectHasError,
  selectCurrentPage,
  selectTotalPages,
  selectSearchQuery,
  selectRemoveSearchQuery,
  selectTitleReplacement,
} from './BreadcrumbBarSelector';

import BreadcrumbBar from './BreadcrumbBar';

// map state to props
const mapStateToProps = state => ({
  resourceSwitcherItems: selectResourceSwitcherItems(state),
  isSwitcherOpen: selectIsSwitcherOpen(state),
  resourceUrl: selectResourceUrl(state),
  isLoadingResources: selectIsLoadingResources(state),
  hasError: selectHasError(state),
  currentPage: selectCurrentPage(state),
  totalPages: selectTotalPages(state),
  searchQuery: selectSearchQuery(state),
  removeSearchQuery: selectRemoveSearchQuery(state),
  titleReplacement: selectTitleReplacement(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { breadcrumbBar: reducer };

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(BreadcrumbBar);
