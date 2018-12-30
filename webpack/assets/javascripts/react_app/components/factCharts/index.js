import React from 'react';
import { connect } from 'react-redux';
import { Modal, Button, OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';
import { bindMethods, noop } from '../../common/helpers';
import DonutChart from '../common/charts/DonutChart';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';
import { STATUS } from '../../constants';
import * as FactChartActions from '../../redux/actions/factCharts/';
import {
  sprintf,
  ngettext as n__,
  translate as __,
} from '../../../react_app/common/I18n';
import { navigateToSearch } from '../../../services/charts/DonutChartService';
import {
  selectHostCount,
  selectFactChart,
  selectDisplayModal,
} from './FactChartSelectors';

class FactChart extends React.Component {
  constructor(props) {
    super(props);
    bindMethods(this, ['openModal', 'closeModal']);
  }

  openModal() {
    const {
      showModal,
      getChartData,
      data: { id, path, title },
    } = this.props;

    getChartData(path, id);
    showModal(id, title);
  }

  closeModal() {
    this.props.closeModal();
  }

  render() {
    const {
      factChart,
      hostsCount,
      data: { id, title, search },
      modalToDisplay,
    } = this.props;

    const handleChartClick =
      search && search.match(/=$/) ? null : navigateToSearch.bind(null, search);

    const chartProps = {
      data: factChart.chartData ? factChart.chartData : null,
      key: `chart-${id}`,
      onclick: handleChartClick,
    };

    const chart = <DonutChart {...chartProps} config="large" />;

    const requestErrorMsg =
      factChart.loaderStatus === STATUS.ERROR
        ? __('Request Failed')
        : __('No data available');

    const error = modalToDisplay ? (
      <MessageBox
        msg={requestErrorMsg}
        icontype="error-circle-o"
        key={`message-${id}`}
      />
    ) : (
      false
    );

    const tooltip = (
      <Tooltip id={`viewChartTooltip-${id}`}>
        {__('Show distribution chart')}
      </Tooltip>
    );

    return (
      <div>
        <OverlayTrigger placement="top" overlay={tooltip}>
          <Button onClick={this.openModal}>{__('View Chart')}</Button>
        </OverlayTrigger>
        {modalToDisplay && (
          <Modal show onHide={this.closeModal}>
            <Modal.Header closeButton>
              <Modal.Title>
                <b>{sprintf(__('Fact distribution chart - %s '), title)}</b>
                {hostsCount && (
                  <small>
                    {sprintf(
                      n__('(%s host)', '(%s hosts)', hostsCount),
                      hostsCount
                    )}
                  </small>
                )}
              </Modal.Title>
            </Modal.Header>
            <Modal.Body>
              <div id="factChartModalBody">
                <Loader status={factChart.loaderStatus}>
                  {[chart, error]}
                </Loader>
              </div>
            </Modal.Body>
          </Modal>
        )}
      </div>
    );
  }
}

FactChart.propTypes = {
  data: PropTypes.shape({
    id: PropTypes.number.isRequired,
    title: PropTypes.string,
    search: PropTypes.string,
  }).isRequired,
  factChart: PropTypes.object,
  modalToDisplay: PropTypes.bool,
  hostsCount: PropTypes.number,
  getChartData: PropTypes.func,
  showModal: PropTypes.func,
  closeModal: PropTypes.func,
};

FactChart.defaultProps = {
  factChart: {},
  modalToDisplay: false,
  hostsCount: 0,
  getChartData: noop,
  showModal: noop,
  closeModal: noop,
};

const mapStateToProps = (state, ownProps) => ({
  factChart: selectFactChart(state),
  hostsCount: selectHostCount(state),
  modalToDisplay: selectDisplayModal(state, ownProps.data.id),
});

export default connect(
  mapStateToProps,
  FactChartActions
)(FactChart);
