import React from 'react';
import { shallow } from 'enzyme';
import StatisticsChartsList from './StatisticsChartsList';
import { statisticsData } from './StatisticsChartsList.fixtures';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import immutable from 'seamless-immutable';
const mockStore = configureMockStore([thunk]);

describe('StatisticsChartsList', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('should render no panels for empty data', () => {
    const store = mockStore({
      statistics: immutable({ charts: [] })
    });
    const wrapper = shallow(
      <StatisticsChartsList store={store} data={statisticsData} />
    );

    expect(
      wrapper.render().find('.statistics-charts-list-panel').length
    ).toEqual(0);
  });

  it('should render two panels for fixtures data', () => {
    const store = mockStore({
      statistics: immutable({ charts: statisticsData })
    });

    const wrapper = shallow(
      <StatisticsChartsList store={store} data={statisticsData} />
    );

    expect(
      wrapper.render().find('.statistics-charts-list-panel').length
    ).toEqual(2);
  });
});
