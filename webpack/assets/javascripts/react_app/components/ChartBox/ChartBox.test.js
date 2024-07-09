import { shallow } from 'enzyme';
import React from 'react';
import ChartBox from './ChartBox';
import { classFunctionUnitTest } from '../../common/testHelpers';

jest.unmock('../../../services/charts/DonutChartService');
jest.unmock('./');

describe('ChartBox', () => {
  const setup = ({ status, chart = { id: '2' } }) =>
    shallow(
      <ChartBox
        type="donut"
        chart={chart}
        noDataMsg="no data"
        status="PENDING"
        errorText="some error"
        title="some title"
        tip="sone tooltip"
        {...chart}
      />
    );

  it('pending', () => {
    const box = setup({ status: 'PENDING' });

    expect(box).toMatchSnapshot();
  });

  it('error', () => {
    const box = setup({ status: 'ERROR' });

    expect(box).toMatchSnapshot();
  });

  it('resolved', () => {
    const box = setup({
      chart: { id: '2', data: [[1, 2]] },
      status: 'RESOLVED',
    });

    expect(box).toMatchSnapshot();
  });

  it('render modal', () => {
    const box = setup({
      chart: { id: '2', data: [[1, 2]] },
      status: 'RESOLVED',
    });
    expect(box.find('.chart-box-modal').props().isOpen).toBeFalsy();
    box.find('.panel-title').simulate('click');
    box.update();
    expect(box.find('.chart-box-modal').props().isOpen).toBeTruthy();
  });
});
