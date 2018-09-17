import { connect } from 'react-redux';
import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import * as HostsActions from '../../../redux/actions/hosts/powerStatus';
import PowerStatusInner from './powerStatusInner';

class PowerStatus extends React.Component {
  componentDidMount() {
    const {
      data: { id, url },
      getHostPowerState,
    } = this.props;

    getHostPowerState({ id, url });
  }

  render() {
    return <PowerStatusInner {...this.props.power} />;
  }
}

PowerStatus.propTypes = {
  data: PropTypes.shapeOf({
    id: PropTypes.string.isRequired,
    url: PropTypes.string.isRequired,
  }).isRequired,
  power: PropTypes.shapeOf({ ...PowerStatusInner.propTypes }),
  getHostPowerState: PropTypes.func,
};

PowerStatus.defaultProps = {
  power: {},
  getHostPowerState: noop,
};

const mapStateToProps = (state, ownProps) => ({
  power: state.hosts.powerStatus[ownProps.data.id] || {},
});

export default connect(
  mapStateToProps,
  HostsActions
)(PowerStatus);
