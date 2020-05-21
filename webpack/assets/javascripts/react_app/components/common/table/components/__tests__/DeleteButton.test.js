import React from 'react';
import { shallow } from '@theforeman/test';
import { Button } from 'patternfly-react';
import DeleteButton from '../DeleteButton';

describe('DeleteButton', () => {
  it('should render delete button on active', () => {
    const view = shallow(
      <DeleteButton active id={1} name="KVM" controller="models" />
    );
    const button = view.find(Button);
    expect(button.props()['data-method']).toBe('delete');
    expect(button.props()['data-confirm']).toBe('Delete KVM?');
    expect(button.props().href).toBe('models/1-KVM');
    expect(button.props().children).toBe('Delete');
  });
  it('should render nothing on non-active', () => {
    const view = shallow(
      <DeleteButton id={1} name="KVM" controller="models" />
    );
    expect(view.find(Button)).toHaveLength(0);
  });
});
