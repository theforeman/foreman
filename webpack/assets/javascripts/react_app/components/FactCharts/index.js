import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { get } from '../../redux/API';

import FactChart from './FactChart';
import { openModal, closeModal } from './slice';

import { FACT_CHART } from './FactChartConstants';
import {
  selectHostCount,
  selectDisplayModal,
  selectFactChartStatus,
  selectFactChartData,
} from './FactChartSelectors';

const ConnectedFactChart = ({ id, path, title, search }) => {
  const key = `${FACT_CHART}_${id}`;
  const hostsCount = useSelector(state => selectHostCount(state, key));
  const status = useSelector(state => selectFactChartStatus(state, key));
  const chartData = useSelector(state => selectFactChartData(state, key));
  const modalToDisplay = useSelector(state => selectDisplayModal(state, id));
  const dispatch = useDispatch();
  const dispatchCloseModal = () => dispatch(closeModal());
  const dispatchOpenModal = () => {
    dispatch(get({ key, url: path }));
    dispatch(openModal({ id, title }));
  };

  return (
    <FactChart
      id={id}
      title={title}
      search={search}
      status={status}
      hostsCount={hostsCount}
      chartData={chartData}
      modalToDisplay={modalToDisplay}
      openModal={dispatchOpenModal}
      closeModal={dispatchCloseModal}
    />
  );
};

ConnectedFactChart.propTypes = {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  path: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  search: PropTypes.string,
};

ConnectedFactChart.defaultProps = {
  search: null,
};

export default ConnectedFactChart;
