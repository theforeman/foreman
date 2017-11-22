import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import React from 'react';
import { Status } from './';
import { state } from './status.fixutres';

describe('Status', () => {
  it('status 1 should render ok icon', () => {
    const wrapper = shallow(<Status data={{ type: 'status1', id: 1 }} status={state.status1[1]} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('status 1 should render error icon', () => {
    const wrapper = shallow(<Status data={{ type: 'status1', id: 2 }} status={state.status1[2]} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('status 2 should render ok icon', () => {
    const wrapper = shallow(<Status data={{ type: 'status2', id: 1 }} status={state.status2[1]} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('status 2 should render error icon', () => {
    const wrapper = shallow(<Status data={{ type: 'status2', id: 2 }} status={state.status2[2]} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('status 2 should render warning icon', () => {
    const wrapper = shallow(<Status data={{ type: 'status2', id: 3 }} status={state.status2[3]} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should render a message', () => {
    const wrapper = shallow(<Status
        getMessage="message1"
        data={{ type: 'status2', id: 2 }}
        status={state.status2[1]}
      />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
