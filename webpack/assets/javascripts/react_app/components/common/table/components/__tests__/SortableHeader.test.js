import React from 'react';
import { shallow } from '@theforeman/test';
import SortalbeHeader from '../SortableHeader';

describe('SortalbeHeader', () => {
  it('should render no icon if sortOrder is null', () => {
    const view = shallow(
      <SortalbeHeader onClick={jest.fn()} sortOrder={null}>
        Header Title
      </SortalbeHeader>
    );
    expect(view.find('i')).toHaveLength(0);
  });

  it('should render fa-sort-asc icon if sortOrder is asc', () => {
    const view = shallow(
      <SortalbeHeader onClick={jest.fn()} sortOrder="asc">
        Header Title
      </SortalbeHeader>
    );
    expect(view.find('i')).toHaveLength(1);
    expect(view.find('i').props().className).toBe('fa fa-sort-asc');
  });

  it('should render fa-sort-desc icon if sortOrder is desc', () => {
    const view = shallow(
      <SortalbeHeader onClick={jest.fn()} sortOrder="desc">
        Header Title
      </SortalbeHeader>
    );
    expect(view.find('i')).toHaveLength(1);
    expect(view.find('i').props().className).toBe('fa fa-sort-desc');
  });

  it('should trigger onClick when clicked', () => {
    const clickFnc = jest.fn();
    const view = shallow(
      <SortalbeHeader onClick={clickFnc}>Header Title</SortalbeHeader>
    );
    expect(clickFnc).not.toBeCalled();
    view.simulate('click');
    expect(clickFnc).toBeCalled();
  });

  it('should render children in the link text', () => {
    const view = shallow(
      <SortalbeHeader onClick={jest.fn()}>Text</SortalbeHeader>
    );
    expect(view.find('a').text()).toBe('Text');
  });
});
