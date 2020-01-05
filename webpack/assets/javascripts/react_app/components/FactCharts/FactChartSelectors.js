import { createSelector } from 'reselect';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../redux/API/APISelectors';
import { FACT_CHART } from './FactChartConstants';

export const selectFactChartData = state =>
  selectAPIResponse(state, FACT_CHART).values || [];

export const selectFactChartStatus = state =>
  selectAPIStatus(state, FACT_CHART);

const hostCounter = (accumulator, currentValue) => accumulator + currentValue;

export const selectHostCount = createSelector(selectFactChartData, chartData =>
  chartData.length ? chartData.map(item => item[1]).reduce(hostCounter) : 0
);

export const selectFactChart = state => state.factChart;

export const selectDisplayModal = (state, id) =>
  selectFactChart(state).modalToDisplay[id] || false;
