jest.unmock('./ChartBox');
jest.unmock('../../../services/ChartService');

import React from 'react';
import { mount } from 'enzyme';
import ChartBox from './ChartBox';
global.patternfly = {
  pfSetDonutChartTitle: jest.fn()
};

describe('ChartBox', () => {
  let chart, noDataMsg, errorText;

  beforeEach(() => {
    chart = {
      id: '2'
    };
    noDataMsg = 'no data';
    errorText = 'some error';
  });

  it('pending', () => {
    const box = mount(
      <ChartBox
        chart={chart}
        noDataMsg={noDataMsg}
        status={'PENDING'}
        errorText={errorText}
        {...chart}
      />
    );

    expect(box.find('.spinner.spinner-lg').length).toBe(1);
  });

  it('error', () => {
    const box = mount(
      <ChartBox
        chart={chart}
        noDataMsg={noDataMsg}
        status={'ERROR'}
        errorText={errorText}
        {...chart}
      />
    );

    expect(box.find('.pficon.pficon-error-circle-o').length).toBe(1);
  });

  it('resolved', () => {
    const box = mount(
      <ChartBox
        chart={{ data: [[1, 2]] }}
        noDataMsg={noDataMsg}
        status={'RESOLVED'}
        errorText={errorText}
        {...chart}
      />
    );

    expect(box.find('.c3-statistics-pie.small').length).toBe(1);
  });
});
