import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as actions from './FillActions';
import reducer from './FillReducer';

import Fill from './Fill';

// map state to props
const mapStateToProps = state => ({
  components: state.extendable,
});

// map action dispatchers to props
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const reducers = { extendable: reducer };

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Fill);
