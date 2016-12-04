import React, {PropTypes} from 'react';
import c3 from 'c3';
import MessageBox from '../common/MessageBox';

class Chart extends React.Component {
  constructor(props) {
    super(props);
  }

  hasData() {
    return !!this.props.config.data.columns.length;
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
    const hasData = this.props.config.data.columns.length;
    const msg = this.props.noDataMsg || 'No data available';

    return hasData ?
      <div className={this.props.cssClass} id={this.props.id + 'Chart'}></div> :
      (
        <MessageBox msg={msg} icontype="info"></MessageBox>
      );
  }
}

Chart.PropTypes = {
  config: PropTypes.object.isRequired,
  id: PropTypes.string.isRequired,
  noDataMsg: PropTypes.string,
  cssClass: PropTypes.string,
  setTitle: PropTypes.func
};

export default Chart;
