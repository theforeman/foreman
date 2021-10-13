import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import ImpersonateIcon from './ImpersonateIcon';

import * as ImpersonateIconActions from './ImpersonateIconActions';

const mapDispatchToProps = (dispatch) =>
  bindActionCreators(ImpersonateIconActions, dispatch);

export default connect(null, mapDispatchToProps)(ImpersonateIcon);
