import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './BreadcrumbBarActions';
import reducer from './BreadcrumbBarReducer';

import BreadcrumbBar from './BreadcrumbBar';

// map state to props
const mapStateToProps = ({ breadcrumbBar }) => ({
  resourceSwitcherItems: breadcrumbBar.resourceSwitcherItems,
  isSwitcherOpen: breadcrumbBar.isSwitcherOpen,
  resourceUrl: breadcrumbBar.resourceUrl,
  isLoadingResources: breadcrumbBar.isLoadingResources,
  hasError: breadcrumbBar.requestError !== null,
  currentPage: breadcrumbBar.currentPage,
  totalPages: breadcrumbBar.pages,
  searchQuery: breadcrumbBar.searchQuery,
  removeSearchQuery: breadcrumbBar.removeSearchQuery,
  titleReplacement: breadcrumbBar.titleReplacement,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { breadcrumbBar: reducer };

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(BreadcrumbBar);
