import React from 'react';
import PropTypes from 'prop-types';
import c3 from 'c3';
import MessageBox from '../MessageBox';

class Chart extends React.Component {
  constructor(props) {
    super(props);
  }

  hasData() {
    const config = this.props.config;

    return (
      config && config.data && config.data.columns && config.data.columns.length
    );
  }

  drawChart() {
    if (this.hasData()) {
      this.chart = c3.generate(this.props.config);

      if (this.props.setTitle) {
        this.props.setTitle(this.props.config);
      }
    } else {
      this.chart = undefined;
    }
  }

  componentDidMount() {
    this.drawChart();
  }

  componentDidUpdate() {
    this.drawChart();
  }

  componentWillUnmount() {
    if (this.chart) {
      this.chart = this.chart.destroy();
    }
  }

  render() {
    const msg = this.props.noDataMsg || 'No data available';

    return this.hasData() ? (
      <div className={this.props.className} data-id={this.props.config.id} />
    ) : (
      <MessageBox msg={msg} icontype="info" />
    );
  }
}

Chart.propTypes = {
  config: PropTypes.object.isRequired,
  noDataMsg: PropTypes.string,
  setTitle: PropTypes.func,
};

export default Chart;
