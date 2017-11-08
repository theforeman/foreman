import { connect } from 'react-redux';
import React from 'react';

import * as HostsActions from '../../../redux/actions/hosts/powerStatus/';

import PowerStatusInner from './powerStatusInner';

class PowerStatus extends React.Component {
  componentDidMount() {
    const { data: { id, url }, getHostPowerState } = this.props;

    getHostPowerState({ id, url });
  }

  render() {
    return <PowerStatusInner {...this.props.power} />;
  }
}

const mapStateToProps = (state, ownProps) => ({
  power: state.hosts.powerStatus[ownProps.data.id] || {},
});

export default connect(mapStateToProps, HostsActions)(PowerStatus);
