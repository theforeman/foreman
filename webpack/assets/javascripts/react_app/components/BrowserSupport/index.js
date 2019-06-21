import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './BrowserSupportActions';
import BrowserSupport from './BrowserSupport';

const mapStateToProps = state => ({
  show: state.browserSupport.show,
  browserName: state.browserSupport.browserName,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(BrowserSupport);
