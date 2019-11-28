import { createSelector } from 'reselect';

export const selectFactChartAPI = state => state.factChartAPI;

export const selectFactChartData = state => selectFactChartAPI(state).chartData;

const hostCounter = (accumulator, currentValue) => accumulator + currentValue;

export const selectHostCount = createSelector(selectFactChartData, chartData =>
  chartData.length ? chartData.map(item => item[1]).reduce(hostCounter) : 0
);

export const selectFactChart = state => state.factChart;

export const selectDisplayModal = (state, id) =>
  state.factChart.modalToDisplay[id] || false;
