import { compose, bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { callOnMount } from '../common/HOC';

import * as actions from './ReactAppActions';
import reducer from './ReactAppReducer';
import browserSupportReducer from '../components/BrowserSupport/BrowserSupportReducer';
import ReactApp from './ReactApp';
import { selectReactAppMetadata } from './ReactAppSelectors';

// map state to props
const mapStateToProps = state => ({
  stateMetadata: selectReactAppMetadata(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const reducers = { app: reducer, browserSupport: browserSupportReducer };

export default compose(
  connect(
    mapStateToProps,
    mapDispatchToProps
  ),
  callOnMount(({ initializeMetadata, data: { metadata } }) =>
    initializeMetadata(metadata)
  )
)(ReactApp);
