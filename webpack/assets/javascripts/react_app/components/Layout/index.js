import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './LayoutActions';
import reducer from './LayoutReducer';

import Layout from './Layout';

// map state to props
const mapStateToProps = ({ layout }) => ({
  items: layout.items,
  isLoading: layout.isLoading,
  activeMenu: layout.activeMenu,
  currentOrg: layout.currentOrg,
  currentLoc: layout.currentLoc,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { layout: reducer };

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(Layout);
