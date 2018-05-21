import React from 'react';
import PropTypes from 'prop-types';
import MessageBox from '../../common/MessageBox';
import { noop } from '../../../common/helpers';
import Normalizer from './Normalizer';
import Loader from '../../common/Loader';
import { STATUS } from '../../../constants';
import TimeseriesChart from '../../common/charts/TimeseriesChart';

class HostChart extends React.Component {
  componentDidMount() {
    const { data: { name, url } } = this.props;
    this.props.getChartData(url, name);
  }
  render() {
    const {
      charts, data: { name, type },
    } = this.props;

    const chartData = Object.keys(charts || {})
      .filter(cName => cName === name)
      .map(cName => charts[cName]);
    const data = chartData.length > 0 ?
      Object.assign({}, { ...chartData[0], results: Normalizer(chartData[0].results) }) :
      { status: STATUS.PENDING, results: [], error: null };

    return (
      <Loader status={data.status}>
      {[
        <TimeseriesChart key={`${name}-chart`} data={data.results} type={type} />,
        <MessageBox msg={data.error} key={`${name}-error`} icontype="error-circle-o" />,
      ]}
      </Loader>
    );
  }
}

HostChart.propTypes = {
  data: PropTypes.shape({
    url: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    type: PropTypes.oneOf(['area', 'line']),
  }),
  getChartData: PropTypes.func.isRequired,
  isLoadingData: PropTypes.bool,
  chartData: PropTypes.object,
};

HostChart.defaultProps = {
  data: {
    type: 'line',
  },
  getChartData: noop,
};

export default HostChart;
