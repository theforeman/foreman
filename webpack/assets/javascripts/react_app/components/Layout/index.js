import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import * as actions from './LayoutActions';
import reducer from './LayoutReducer';
import {
  patternflyMenuItemsSelector,
  selectActiveMenu,
  selectCurrentOrganization,
  selectCurrentLocation,
  selectIsLoading,
} from './LayoutSelectors';

import Layout from './Layout';

// map state to props
const mapStateToProps = state => ({
  items: patternflyMenuItemsSelector(state),
  isLoading: selectIsLoading(state),
  activeMenu: selectActiveMenu(state),
  currentOrganization: selectCurrentOrganization(state),
  currentLocation: selectCurrentLocation(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { layout: reducer };

// export connected component
export default withRouter(
  connect(
    mapStateToProps,
    mapDispatchToProps
  )(Layout)
);
