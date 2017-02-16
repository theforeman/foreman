import React from 'react';
import helpers from '../../common/helpers';
import HostsStore from '../../stores/HostsStore';
import HostsActions from '../../actions/HostsActions';
import PowerStatus from './PowerStatus';
import {STATUS} from '../../constants';

class PowerStatusContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { status: STATUS.PENDING };
    helpers.bindMethods(this, [
      'onChange',
      'onError']
    );
  }

  componentDidMount() {
    HostsStore.addChangeListener(this.onChange);
    HostsStore.addErrorListener(this.onError);
    HostsActions.getHostPowerState(this.props.url);
  }

  componentWillUnmount() {
    HostsStore.removeChangeListener(this.onChange);
    HostsStore.removeErrorListener(this.onError);
  }

  onChange(event) {
    const id = parseInt(event.id, 10);

    if (id === this.props.id) {
      this.updateState(HostsStore.getHostData(id));
    }
  }

  onError(info) {
    if (this.props.id === info.id) {
      this.setState({
        status: STATUS.ERROR,
        statusText: info.textStatus
      });
    }
  }

  updateState(host) {
    this.setState({
      power: host.power.state,
      title: host.power.title,
      statusText: host.power.statusText,
      status: STATUS.RESOLVED
    });
  }

  render() {
    return (
      <PowerStatus
        state={this.state.power}
        title={this.state.title}
        loadingStatus={this.state.status}
        statusText={this.state.statusText}
      />
    );
  }
}

export default PowerStatusContainer;
