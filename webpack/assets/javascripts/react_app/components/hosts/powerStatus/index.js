import React from 'react';
import { connect } from 'react-redux';
import * as HostsActions from '../../../redux/actions/hosts/powerStatus/';
import PowerStatusInner from './powerStatusInner';

class PowerStatus extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    const { data: { id, url }, getHostPowerState } = this.props;

    getHostPowerState({ id, url });
  }

  render() {
    return <PowerStatusInner {...this.props.power} />;
  }
}

const mapStateToProps = (state, ownProps) => {
  return {
    power: state.hosts.powerStatus[ownProps.data.id] || {},
  };
};

export default connect(mapStateToProps, HostsActions)(PowerStatus);
