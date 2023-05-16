import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Card,
  CardBody,
  CardTitle,
  CardHeader,
  Modal,
  ModalVariant,
} from '@patternfly/react-core';
import classNames from 'classnames';
import DonutChart from '../common/charts/DonutChart';
import BarChart from '../common/charts/BarChart';
import Loader from '../common/Loader';
import MessageBox from '../common/MessageBox';
import { translate as __ } from '../../common/I18n';
import './ChartBox.css';

const ChartBox = ({
  chart,
  type,
  config,
  title,
  status,
  errorText,
  className,
  tip,
}) => {
  const [showModal, setShowModal] = useState(false);

  const openModal = () => {
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  const components = {
    donut: DonutChart,
    bar: BarChart,
  };
  const Chart = components[type];
  const dataFiltered = chart.data && chart.data.filter(arr => arr[1] !== 0);
  const hasChartData = dataFiltered && dataFiltered.length > 0;
  const headerProps = hasChartData
    ? {
        onClick: openModal,
        title: tip,
        'data-toggle': 'tooltip',
        'data-placement': 'top',
      }
    : {};
  const chartProps = {
    searchUrl: chart.search && !chart.search.match(/=$/) ? chart.search : null,
    data: chart.data ? chart.data : undefined,
    key: `${chart.id}-chart`,
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

  const panelChart = <Chart {...chartPropsForType[type]} config={config} />;
  const error = (
    <MessageBox
      msg={errorText}
      key={`${chart.id}-error`}
      icontype="error-circle-o"
    />
  );

  return (
    <Card className={classNames('chart-box', className)} key={chart.id}>
      <CardHeader>
        <CardTitle className="pointer panel-title" {...headerProps}>
          {title}
        </CardTitle>
      </CardHeader>
      <CardBody>
        <Loader status={status}>{[panelChart, error]}</Loader>
        <Modal
          className="chart-box-modal"
          variant={ModalVariant.small}
          title={title}
          isOpen={showModal}
          onClose={closeModal}
        >
          <Chart {...chartProps} config={config} />
        </Modal>
      </CardBody>
    </Card>
  );
};

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
