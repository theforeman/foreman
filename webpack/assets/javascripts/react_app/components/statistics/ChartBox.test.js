import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';
import ChartBox from './ChartBox';

jest.unmock('../../../services/ChartService');
jest.unmock('./ChartBox');

describe('ChartBox', () => {
  const setup = ({ status, chart = { id: 2 } }) => shallow(<ChartBox
    type="donut"
    chart={chart}
    noDataMsg='no data'
    status="PENDING"
    errorText='some error'
    title='some title'
    tip='sone tooltip'
    {...chart}
  />);

  it('pending', () => {
    const box = setup({ status: 'PENDING' });

    expect(toJson(box)).toMatchSnapshot();
  });

  it('error', () => {
    const box = setup({ status: 'ERROR' });

    expect(toJson(box)).toMatchSnapshot();
  });

  it('resolved', () => {
    const box = setup({
      chart: { id: '2', data: [[1, 2]] },
      status: 'RESOLVED',
    });

    expect(toJson(box)).toMatchSnapshot();
  });

  it('render modal', () => {
    const box = setup({
      chart: { id: '2', data: [[1, 2]] },
      status: 'RESOLVED',
    });
    expect(box.find('Modal').length).toBe(0);
    box.setState({ showModal: true });
    expect(box.find('Modal').length).toBe(1);
  });
});
