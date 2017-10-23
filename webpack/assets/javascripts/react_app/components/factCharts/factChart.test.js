import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import React from 'react';
import FactChart from './';
import Store from '../../redux';


describe('factCharts', () => {
  it('should render closed', () => {
    const wrapper = shallow(<FactChart data={ { id: 1, title: 'test title' } } store={ Store }/>);
    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('should render open', () => {
    const wrapper = shallow(<FactChart data={ { id: 1, title: 'test title' } } modalToDisplay store={ Store }/>);
    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('should open modal after click', () => {
    const props = { onClick: jest.fn(), data: { id: 1 } };
    const wrapper = shallow(<FactChart store={ Store } { ...props } />);

    wrapper.simulate('click');
    expect(props.onClick).toBeCalled();
  });
});
