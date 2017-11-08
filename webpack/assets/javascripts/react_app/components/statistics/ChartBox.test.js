// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

jest.unmock('./ChartBox');
jest.unmock('../../../services/ChartService');

import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import ChartBox from './ChartBox';
global.patternfly = {
  pfSetDonutChartTitle: jest.fn(),
};

describe('ChartBox', () => {
  let chart, noDataMsg, errorText;

  beforeEach(() => {
    chart = {
      id: '2',
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

    expect(toJson(box)).toMatchSnapshot();
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

    expect(toJson(box)).toMatchSnapshot();
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

    expect(box.find('.c3-statistics-pie.small').at(0).length).toBe(1);
  });
});
