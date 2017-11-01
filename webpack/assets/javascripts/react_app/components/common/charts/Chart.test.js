// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

jest.unmock('./Chart');
jest.unmock('../MessageBox');
jest.mock('c3');

import React from 'react';
import { shallow, mount } from 'enzyme';
import Chart from './Chart';
import c3 from 'c3';
// setup functions

describe('Chart', () => {
  describe('has no data', () => {
    it('renders MessageBox with noDataMsg property', () => {
      const config = {
        data: {
          columns: [],
        },
      };
      const chart = shallow(
        <Chart config={config} noDataMsg={'No data here'} />
      );

      expect(chart.getElement().props.msg).toBe('No data here');
      expect(chart.getElement().props.icontype).toBe('info');
    });

    it('renders MessageBox with default no data message', () => {
      const config = {
        data: {
          columns: [],
        },
      };

      const chart = shallow(<Chart config={config} />);

      expect(chart.getElement().props.msg).toBe('No data available');
      expect(chart.getElement().props.icontype).toBe('info');
    });

    it('does not display no data message if hasData is true', () => {
      const config = {
        data: {
          columns: [1, 2],
        },
      };
      const chart = shallow(<Chart config={config} />);

      expect(chart.getElement().type.name).not.toBe('MessageBox');
    });
  });

  describe('draws chart', () => {
    let config;

    /*
      unmount calls chart.destroy
      set c3.generate return value property destroy to value
      so that unmount will throw 'is not a function, error when calling chart.destroy()
      this facilitates checking that 'destroy' is called
    */
    c3.generate = jest.fn().mockReturnValue({ destroy: '' });

    beforeEach(() => {
      config = {
        id: 'operatingsystem',
        bindto: '#operatingsystem',
        donut: {
          width: 15,
          label: { show: false },
        },
        data: {
          type: 'donut',
          columns: [
            ['Fedora 21', 3],
            ['Ubuntu 14.04', 4],
            ['Centos 7', 2],
            ['Debian 8', 1],
          ],
        },
        tooltip: {
          show: true,
          contents: 'tooltip',
        },
        legend: { show: false },
        padding: {
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        },
      };
    });

    it('renders chart shell', () => {
      const chart = shallow(<Chart config={config} />);

      expect(chart.is('div[data-id="operatingsystem"]')).toBe(true);

      expect(chart.getElement().type).toBe('div');
    });

    describe('calls c3.generate when appropriate', () => {
      it('calls c3 generate with config', () => {
        mount(<Chart id="operatingsystem" config={config} />);

        expect(c3.generate).toBeCalledWith(config);
      });
      it('does not call c3 generate with no data', () => {
        config.data.columns = [];
        c3.generate.mockClear();

        mount(<Chart id="operatingsystem" config={config} />);

        expect(c3.generate).not.toBeCalled();
      });
    });

    describe('sets title when appropriate', () => {
      it('calls setTitle if present', () => {
        const setTitle = jest.fn();

        mount(
          <Chart id="operatingsystem" setTitle={setTitle} config={config} />
        );

        expect(setTitle).toBeCalledWith(config);
      });
      it('does not call setTitle if not supplied', () => {
        const setTitle = jest.fn();

        mount(<Chart id="operatingsystem" config={config} />);

        expect(setTitle).not.toBeCalled();
      });
    });

    describe('life cycle events', () => {
      it('update', () => {
        let chart = mount(<Chart id="operatingsystem" config={config} />);

        chart.update();

        expect(c3.generate).toHaveBeenCalled();
      });
      it('unmount', () => {
        let chart = mount(<Chart id="operatingsystem" config={config} />);

        // a very peculiar way to prove that chart is destroyed when unmounting
        expect(() => {
          chart.unmount();
        }).toThrowError('this.chart.destroy is not a function');
      });
    });
  });
});
