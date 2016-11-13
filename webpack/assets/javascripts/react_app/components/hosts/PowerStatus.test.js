jest.unmock('./PowerStatus');

import React from 'react';
import { mount, shallow } from 'enzyme';
import PowerStatus from './PowerStatus';

describe('PowerStatus', () => {

  it('pending', () => {
    const box = mount(
      <PowerStatus
        loadingStatus="PENDING"
      />
    );

    expect(box.find('.spinner.spinner-xs').length).toBe(1);
  });

  it('error', () => {
    const box = shallow(
      <PowerStatus
        loadingStatus="ERROR"
      />
    );

    const error = box.children().at(1);

    expect(error.find('.fa.fa-power-off.host-power-status.na').length).toBe(1);
    expect(box.find('.fa.fa-power-off.host-power-status.on').length).toBe(0);
    expect(box.find('.fa.fa-power-off.host-power-status.off').length).toBe(0);
    expect(box.find('.fa.fa-power-off.host-power-status').length).toBe(2);
  });

  it('resolved', () => {
    const box = shallow(
      <PowerStatus
        state="on"
        title="On"
        loadingStatus="RESOLVED"
     />
    );
    const status = box.children().at(0);

    expect(status.find('.fa.fa-power-off.host-power-status.on').length).toBe(1);
    expect(status.find('.fa.fa-power-off.host-power-status.off').length).toBe(0);
    expect(status.find('.fa.fa-power-off.host-power-status.na').length).toBe(0);
    expect(status.find('.fa.fa-power-off.host-power-status').length).toBe(1);
    expect(box.find({title: 'On' }).length).toBe(1);
  });

    it('resolved', () => {
    const box = shallow(
      <PowerStatus
        state="off"
        title="Off"
        loadingStatus="RESOLVED"
     />
    );
    const status = box.children().at(0);

    expect(status.find('.fa.fa-power-off.host-power-status.off').length).toBe(1);
    expect(status.find('.fa.fa-power-off.host-power-status.on').length).toBe(0);
    expect(status.find('.fa.fa-power-off.host-power-status.na').length).toBe(0);
    expect(status.find('.fa.fa-power-off.host-power-status').length).toBe(1);
    expect(box.find({title: 'Off' }).length).toBe(1);
  });
});
