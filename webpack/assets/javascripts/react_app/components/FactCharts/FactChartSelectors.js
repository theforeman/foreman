import { createSelector } from 'reselect';
import {
  selectAPIStatus,
  selectAPIResponse,
} from '../../redux/API/APISelectors';

export const selectFactChartData = (state, key) =>
  selectAPIResponse(state, key).values || [];

export const selectFactChartStatus = (state, key) =>
  selectAPIStatus(state, key);

const hostCounter = (accumulator, currentValue) => accumulator + currentValue;

export const selectHostCount = createSelector(selectFactChartData, chartData =>
  chartData.length ? chartData.map(item => item[1]).reduce(hostCounter) : 0
);

export const selectFactChart = state => state.factChart;

export const selectDisplayModal = (state, id) =>
  selectFactChart(state).modalToDisplay[id] || false;
