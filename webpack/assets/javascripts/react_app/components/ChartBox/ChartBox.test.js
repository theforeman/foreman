import { shallow } from '@theforeman/test';
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
    expect(box.find('Modal')).toHaveLength(0);
    box.setState({ showModal: true });
    expect(box.find('Modal')).toHaveLength(1);
  });
  it('shouldComponentUpdate should be called', () => {
    const shouldUpdateSpy = jest.spyOn(
      ChartBox.prototype,
      'shouldComponentUpdate'
    );
    const box = shallow(
      <ChartBox
        id="4"
        type="donut"
        chart={{ id: '4', data: undefined }}
        status="PENDING"
      />
    );
    box.setProps({ status: 'PENDING' });
    expect(shouldUpdateSpy).toHaveBeenCalled();
  });
  it('shouldComponentUpdate', () => {
    const objThis = {
      state: { showModal: false },
      props: { chart: { data: [1, 2] } },
    };

    expect(
      classFunctionUnitTest(ChartBox, 'shouldComponentUpdate', objThis, [
        { chart: { data: [1, 2] } },
        { showModal: false },
      ])
    ).toBe(false);
    expect(
      classFunctionUnitTest(ChartBox, 'shouldComponentUpdate', objThis, [
        { chart: { data: [1, 1] } },
        { showModal: false },
      ])
    ).toBe(true);
    expect(
      classFunctionUnitTest(ChartBox, 'shouldComponentUpdate', objThis, [
        { chart: { data: [1, 2] } },
        { showModal: true },
      ])
    ).toBe(true);
  });
});
