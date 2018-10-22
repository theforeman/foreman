import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './LayoutActions';
import reducer from './LayoutReducer';
import {
  selectLayout,
  patternflyMenuItemsSelector,
  selectCurrentOrganization,
  selectCurrentLocation,
} from './LayoutSelectors';

import Layout from './Layout';

// map state to props
const mapStateToProps = (state) => {
  const layoutState = selectLayout(state);

  return {
    items: patternflyMenuItemsSelector(state),
    isLoading: layoutState.isLoading,
    activeMenu: layoutState.activeMenu,
    currentOrganization: selectCurrentOrganization(state),
    currentLocation: selectCurrentLocation(state),
  };
};

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { layout: reducer };

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(Layout);
