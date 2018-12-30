import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { Modal } from 'patternfly-react';
import { isEqual } from 'lodash';
import classNames from 'classnames';
import { bindMethods } from '../../common/helpers';
import DonutChart from '../common/charts/DonutChart';
import BarChart from '../common/charts/BarChart';
import { navigateToSearch } from '../../../services/charts/DonutChartService';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';

class ChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false };
    bindMethods(this, ['onClick', 'closeModal', 'openModal']);
  }
  shouldComponentUpdate(nextProps, nextState) {
    return (
      !isEqual(this.props.chart, nextProps.chart) ||
      !isEqual(this.state, nextState)
    );
  }

  onClick() {
    this.openModal();
  }

  openModal() {
    this.setState({ showModal: true });
  }

  closeModal() {
    this.setState({ showModal: false });
  }

  render() {
    const { chart, type, config, title, status, className } = this.props;
    const components = {
      donut: DonutChart,
      bar: BarChart,
    };
    const Chart = components[type];
    const dataFiltered = chart.data && chart.data.filter(arr => arr[1] !== 0);
    const hasChartData = dataFiltered && dataFiltered.length > 0;
    const headerProps = hasChartData
      ? {
          onClick: this.onClick,
          title: this.props.tip,
          'data-toggle': 'tooltip',
          'data-placement': 'top',
        }
      : {};
    const handleChartClick =
      chart.search && chart.search.match(/=$/)
        ? null
        : navigateToSearch.bind(null, chart.search);
    const chartProps = {
      data: chart.data ? chart.data : undefined,
      key: `${chart.id}-chart`,
      onclick: handleChartClick,
    };

    const barChartProps = {
      ...chartProps,
      xAxisLabel: chart.xAxisLabel,
      yAxisLabel: chart.yAxisLabel,
    };

    const chartPropsForType = {
      donut: chartProps,
      bar: barChartProps,
    };

    const panelChart = (
      <Chart {...chartPropsForType[type]} config={this.props.config} />
    );
    const error = (
      <MessageBox
        msg={this.props.errorText}
        key={`${this.props.chart.id}-error`}
        icontype="error-circle-o"
      />
    );
    const boxHeader = (
      <h3 className="pointer panel-title" {...headerProps}>
        {title}
      </h3>
    );

    return (
      <Panel
        className={classNames('chart-box', className)}
        header={boxHeader}
        key={chart.id}
      >
        <Panel.Heading>{boxHeader}</Panel.Heading>
        <Panel.Body>
          <Loader status={status}>{[panelChart, error]}</Loader>
          {this.state.showModal && (
            <Modal
              show={this.state.showModal}
              enforceFocus
              onHide={this.closeModal}
            >
              <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
              </Modal.Header>
              <Modal.Body>
                <Chart {...chartProps} config={config} />
              </Modal.Body>
            </Modal>
          )}
        </Panel.Body>
      </Panel>
    );
  }
}

ChartBox.propTypes = {
  status: PropTypes.string.isRequired,
  title: PropTypes.node,
  className: PropTypes.string,
  config: PropTypes.string,
  noDataMsg: PropTypes.string,
  errorText: PropTypes.string,
  type: PropTypes.oneOf(['donut', 'bar']).isRequired,
  chart: PropTypes.object,
  tip: PropTypes.string,
};

ChartBox.defaultProps = {
  title: '',
  className: '',
  config: 'regular',
  noDataMsg: __('No data available'),
  errorText: '',
  chart: {},
  tip: '',
};

export default ChartBox;
