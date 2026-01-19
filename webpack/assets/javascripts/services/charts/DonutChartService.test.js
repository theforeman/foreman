import { getDonutChartConfig } from './DonutChartService';
import {
  inputData,
  inputDataWithLongLabels,
} from '../../react_app/components/common/charts/DonutChart/DonutChart.fixtures';

jest.mock('./ChartService.consts');

describe('getDonutChartConfig', () => {
  describe('data filtering and transformation', () => {
    it('returns empty data array when all values are zero', () => {
      const zeroedData = [
        ['Fedora 21', 0],
        ['Ubuntu 14.04', 0],
        ['Centos 7', 0],
      ];

      const result = getDonutChartConfig({
        data: zeroedData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result.data).toEqual([]);
    });

    it('includes all data values, even zeros', () => {
      const mixedData = [
        ['Fedora 21', 3],
        ['Ubuntu 14.04', 2],
        ['Centos 7', 0],
        ['Debian 8', 0],
      ];

      const result = getDonutChartConfig({
        data: mixedData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      // PF5 Victory charts include all segments, even with zero values
      expect(result.data).toHaveLength(4);
      expect(result.data[0]).toEqual({
        x: 'Fedora 21',
        y: 3,
        name: 'Fedora 21',
      });
      expect(result.data[1]).toEqual({
        x: 'Ubuntu 14.04',
        y: 2,
        name: 'Ubuntu 14.04',
      });
      // Zero values are included
      expect(result.data[2].y).toBe(0);
      expect(result.data[3].y).toBe(0);
    });

    it('transforms data to Victory format with x, y, and name', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result.data).toHaveLength(4);
      result.data.forEach(item => {
        expect(item).toHaveProperty('x');
        expect(item).toHaveProperty('y');
        expect(item).toHaveProperty('name');
      });
    });

    it('extracts custom colors from data', () => {
      const dataWithColors = [
        ['OS 1', 10, '#ff0000'],
        ['OS 2', 20, '#00ff00'],
        ['OS 3', 30, '#0000ff'],
      ];

      const result = getDonutChartConfig({
        data: dataWithColors,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result.colorScale).toEqual(['#ff0000', '#00ff00', '#0000ff']);
    });

    it('handles data without custom colors', () => {
      const dataWithoutColors = [
        ['OS 1', 10],
        ['OS 2', 20],
      ];

      const result = getDonutChartConfig({
        data: dataWithoutColors,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result.colorScale).toBeUndefined();
    });
  });

  describe('label handling', () => {
    it('preserves full labels including long ones', () => {
      const result = getDonutChartConfig({
        data: inputDataWithLongLabels,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      const longLabelItem = result.data.find(item =>
        item.name.includes('extra extra extra extra extra extra extra')
      );

      // Both x and name should contain the full label
      expect(longLabelItem.x).toBe(longLabelItem.name);
      expect(longLabelItem.name).toContain(
        'extra extra extra extra extra extra extra'
      );
    });

    it('preserves all labels as-is', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      result.data.forEach(item => {
        expect(item.x).toBe(item.name);
      });
    });

    it('includes full label in tooltip via labels function', () => {
      const result = getDonutChartConfig({
        data: inputDataWithLongLabels,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      const longLabelItem = result.data.find(item =>
        item.name.includes('extra extra extra extra extra extra extra')
      );

      const tooltipText = result.labels({ datum: longLabelItem });

      // Tooltip should contain full name and percentage
      expect(tooltipText).toContain(longLabelItem.name);
      expect(tooltipText).toMatch(/%$/);
    });
  });

  describe('configuration sizes', () => {
    it('uses regular size configuration', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result.width).toBe(240);
      expect(result.height).toBe(240);
    });

    it('uses medium size configuration', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'medium',
        id: 'test-id',
      });

      expect(result.width).toBe(320);
      expect(result.height).toBe(320);
    });

    it('uses large size configuration', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'large',
        id: 'test-id',
      });

      expect(result.height).toBe(500);
    });
  });

  describe('event handling', () => {
    it('includes click events when onclick is provided', () => {
      const mockOnClick = jest.fn();

      const result = getDonutChartConfig({
        data: inputData,
        onclick: mockOnClick,
        config: 'regular',
        id: 'test-id',
      });

      expect(result.events).toBeDefined();
      expect(result.events).toHaveLength(1);
      expect(result.events[0].target).toBe('data');
    });

    it('includes click events when searchUrl is provided', () => {
      const result = getDonutChartConfig({
        data: inputData,
        searchUrl: '/hosts?search=~VAL~',
        config: 'regular',
        id: 'test-id',
      });

      expect(result.events).toBeDefined();
      expect(result.events).toHaveLength(1);
    });

    it('includes hover events when neither onclick nor searchUrl provided', () => {
      const result = getDonutChartConfig({
        data: inputData,
        config: 'regular',
        id: 'test-id',
      });

      expect(result.events).toBeDefined();
      expect(result.events).toHaveLength(1);
      expect(result.events[0].eventHandlers.onMouseOver).toBeDefined();
      expect(result.events[0].eventHandlers.onMouseOut).toBeDefined();
    });
  });

  describe('tooltip labels', () => {
    it('displays percentage in tooltip', () => {
      const result = getDonutChartConfig({
        data: [
          ['Item 1', 40],
          ['Item 2', 60],
        ],
        config: 'regular',
        id: 'test-id',
      });

      const label1 = result.labels({
        datum: { x: 'Item 1', y: 40, name: 'Item 1' },
      });
      const label2 = result.labels({
        datum: { x: 'Item 2', y: 60, name: 'Item 2' },
      });

      expect(label1).toBe('Item 1: 40.0%');
      expect(label2).toBe('Item 2: 60.0%');
    });
  });

  describe('return structure', () => {
    it('returns required PF5 Victory chart configuration properties', () => {
      const result = getDonutChartConfig({
        data: inputData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'test-id',
      });

      expect(result).toHaveProperty('id');
      expect(result).toHaveProperty('data');
      expect(result).toHaveProperty('width');
      expect(result).toHaveProperty('height');
      expect(result).toHaveProperty('padding');
      expect(result).toHaveProperty('innerRadius');
      expect(result).toHaveProperty('labels');
    });

    it('uses provided id', () => {
      const result = getDonutChartConfig({
        data: inputData,
        config: 'regular',
        id: 'custom-id',
      });

      expect(result.id).toBe('custom-id');
    });

    it('generates id if not provided', () => {
      const result = getDonutChartConfig({
        data: inputData,
        config: 'regular',
      });

      expect(result.id).toBeDefined();
      expect(typeof result.id).toBe('string');
    });
  });
});
