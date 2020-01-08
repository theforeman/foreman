import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import FactChart from './FactChart';
import reducer from './FactChartReducer';
import { openModal, closeModal } from './FactChartActions';
import { FACT_CHART } from './FactChartConstants';
import {
  selectHostCount,
  selectDisplayModal,
  selectFactChartStatus,
  selectFactChartData,
} from './FactChartSelectors';

const ConnectedFactChart = ({ data: { id, path, title, search } }) => {
  const key = `${FACT_CHART}_${id}`;
  const hostsCount = useSelector(state => selectHostCount(state, key));
  const status = useSelector(state => selectFactChartStatus(state, key));
  const chartData = useSelector(state => selectFactChartData(state, key));
  const modalToDisplay = useSelector(state => selectDisplayModal(state, id));
  const dispatch = useDispatch();
  const dispatchCloseModal = () => dispatch(closeModal(id));
  const dispatchOpenModal = () =>
    dispatch(openModal({ id, title, apiKey: key, apiUrl: path }));

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
  data: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    path: PropTypes.string,
    title: PropTypes.string,
    search: PropTypes.string,
  }).isRequired,
};

export default ConnectedFactChart;

export const reducers = { factChart: reducer };
