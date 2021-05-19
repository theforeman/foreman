import React from 'react';
import { shallow, render } from '@theforeman/test';
import { FormSelectOption } from '@patternfly/react-core';

import { emptyOption, validatedOS, osHelperText } from '../RegistrationCommandsPageHelpers'

describe('emptyOption', () => {
  it('when length == 0', () => {
    expect(emptyOption(0)).toEqual(<FormSelectOption label="Nothing to select." value="" />);
  });

  it('when length > 0', () => {
    expect(emptyOption(23)).toEqual(<FormSelectOption label="" value="" />);
  });
});

describe('validatedOS', () => {
  it('no OS id', () => {
    expect(validatedOS('', {})).toEqual('default');
  });

  it('with template', () => {
    expect(validatedOS(1, {name: 'test'})).toEqual('success');
  });

  it('without template', () => {
    expect(validatedOS(1, {name: ''})).toEqual('error');
  });
});

describe('osHelperText', () => {
  it('OS with template', () => {
    const wrapper = shallow(osHelperText(1, [], null, [], {name: 'test'}));
    expect(wrapper.find('span').text()).toMatch(/Initial configuration template: test/)
  });

  it('OS without template', () => {
    const wrapper = shallow(osHelperText(1, [], null, [], {}));
    expect(wrapper.find('span').text()).toMatch(/does not have assigned host_init_config template/)
  });

  it('for host group with OS with template', () => {
    const wrapper = render(osHelperText(null, [{id: 23}], 1, [{ id: 1, inherited_operatingsystem_id: 23 }], { name: 'test'}));

    expect(wrapper.text()).toMatch(/Host group OS/);
    expect(wrapper.text()).toMatch(/Initial configuration template/);
  });

  it('for host group with OS without template', () => {
    const wrapper = render(osHelperText(null, [{id: 23}], 1, [{ id: 1, inherited_operatingsystem_id: 23 }], {}));

    expect(wrapper.text()).toMatch(/Host group OS/);
    expect(wrapper.text()).toMatch(/does not have assigned host_init_config template/);
  });

  it('for host group without OS', () => {
    const wrapper = render(osHelperText(null, [], 1, [{ id: 1, inherited_operatingsystem_id: 23 }], {}));
    expect(wrapper.text()).toMatch(/No OS from host group/);
  });

  it('no OS or host group', () => {
    expect(osHelperText()).toEqual('');
  });
});
