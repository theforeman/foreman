import React from 'react';
import { mount, shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { Provider } from 'react-redux';
import About from './';
import { data } from './about.fixtures';
import store from '../../redux';
import { mockRequest } from '../../mockRequests';

const flushAllPromises = () => new Promise(resolve => setImmediate(resolve));

describe('about page', () => {
  mockRequest({
    url: '/smart_proxies/1/ping',
    response: {
      success: true,
      message: {
        version: '1.16.0-develop',
        modules: {
          facts: '1.16.0',
          dns: '1.16.0',
          dhcp: '1.16.0',
          puppet: '1.16.0',
          logs: '1.16.0',
        },
      },
    },
  });
  mockRequest({
    url: '/compute_resources/1/ping',
    response: {
      status: 'OK',
      message: '',
    },
  });
  mockRequest({
    url: '/compute_resources/2/ping',
    response: {
      status: 'Error',
      message: 'Failed to open TCP connection',
    },
  });
  it('should render', () => {
    const wrapper = shallow(<About data={data} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should have statuses and version fields', async () => {
    const wrapper = mount(<Provider store={store}>
        <About data={data} />
      </Provider>);

    await flushAllPromises();
    wrapper.update();
    expect(wrapper.find('#proxy1_version').text()).toBe('1.16.0-develop');
    expect(wrapper.find('#proxy1_status .pficon-ok')).toHaveLength(1);
    expect(wrapper.find('#compute_resource1_status .pficon-ok')).toHaveLength(1);
    expect(wrapper.find('#compute_resource2_status .pficon-error-circle-o')).toHaveLength(1);
  });
});
