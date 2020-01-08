import React from 'react';
import { Modal, Button, OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';
import { noop } from '../../common/helpers';
import DonutChart from '../common/charts/DonutChart';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';
import { STATUS } from '../../constants';
import { navigateToSearch } from '../../../services/charts/DonutChartService';
import {
  sprintf,
  ngettext as n__,
  translate as __,
} from '../../../react_app/common/I18n';

const FactChart = ({
  hostsCount,
  modalToDisplay,
  status,
  chartData,
  closeModal,
  openModal,
  search,
  id,
  title,
}) => {
  const handleChartClick =
    search && search.match(/=$/) ? null : navigateToSearch.bind(null, search);

  const chartProps = {
    data: chartData,
    key: `chart-${id}`,
    onclick: handleChartClick,
  };

  const chart = <DonutChart {...chartProps} config="large" />;

  const requestErrorMsg =
    status === STATUS.ERROR ? __('Request Failed') : __('No data available');

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
        <Button onClick={openModal}>{__('View Chart')}</Button>
      </OverlayTrigger>
      {modalToDisplay && (
        <Modal show onHide={closeModal}>
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
              <Loader status={status}>{[chart, error]}</Loader>
            </div>
          </Modal.Body>
        </Modal>
      )}
    </div>
  );
};

FactChart.propTypes = {
  modalToDisplay: PropTypes.bool,
  hostsCount: PropTypes.number,
  openModal: PropTypes.func,
  closeModal: PropTypes.func,
  status: PropTypes.string,
  chartData: PropTypes.arrayOf(PropTypes.array),
  search: PropTypes.string,
  title: PropTypes.string,
  id: PropTypes.number.isRequired,
};

FactChart.defaultProps = {
  modalToDisplay: false,
  hostsCount: 0,
  openModal: noop,
  closeModal: noop,
  status: null,
  chartData: null,
  search: null,
  title: '',
};

export default FactChart;
