import { connect } from 'react-redux';

import InterfaceTable from './InterfaceTable';
import * as InterfaceActions from '../../../../redux/actions/hosts/interfaces';

const mapStateToProps = (state, ownProps) => {
  const { interfaces, destroyed } = state.hosts.interfaces;
  return { interfaces, destroyed };
};

export default connect(
  mapStateToProps,
  InterfaceActions
)(InterfaceTable);
