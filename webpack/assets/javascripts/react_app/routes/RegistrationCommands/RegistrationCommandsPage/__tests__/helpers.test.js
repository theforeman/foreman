import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import { emptyOption, validatedOS, osHelperText } from '../RegistrationCommandsPageHelpers';

describe('emptyOption', () => {
  it('when length == 0', () => {
    render(<select>{emptyOption(0)}</select>);

    expect(screen.getByText('Nothing to select.')).toBeInTheDocument();
  });

  it('when length > 0', () => {
    render(<select>{emptyOption(23)}</select>);

    expect(screen.getByRole('option')).toBeInTheDocument();
    expect(screen.queryByText('Nothing to select.')).not.toBeInTheDocument();
  });
});

describe('validatedOS', () => {
  it('no OS id', () => {
    expect(validatedOS('', {})).toEqual('default');
  });

  it('with template', () => {
    expect(validatedOS(1, { name: 'test' })).toEqual('success');
  });

  it('without template', () => {
    expect(validatedOS(1, { name: '' })).toEqual('error');
  });
});

describe('osHelperText', () => {
  it('OS with template', () => {
    render(
      osHelperText(1, [], null, [], { name: 'test', path: '/templates/1' })
    );

    expect(screen.getByText(/Initial configuration template/)).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'test' })).toHaveAttribute(
      'href',
      '/templates/1'
    );
  });

  it('OS without template', () => {
    render(osHelperText(1, [], null, [], { os_path: '/operatingsystems/1' }));

    expect(
      screen.getByText(/does not have assigned host_init_config template/)
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Operating system' })).toHaveAttribute(
      'href',
      '/operatingsystems/1'
    );
  });

  it('for host group with OS with template', () => {
    render(
      osHelperText(
        null,
        [{ id: 23, title: 'RHEL 8' }],
        1,
        [{ id: 1, inherited_operatingsystem_id: 23 }],
        { name: 'test', path: '/templates/1' }
      )
    );

    expect(screen.getByText(/Host group OS: RHEL 8/)).toBeInTheDocument();
    expect(screen.getByText(/Initial configuration template/)).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'test' })).toHaveAttribute(
      'href',
      '/templates/1'
    );
  });

  it('for host group with OS without template', () => {
    render(
      osHelperText(
        null,
        [{ id: 23, title: 'RHEL 8' }],
        1,
        [{ id: 1, inherited_operatingsystem_id: 23 }],
        { os_path: '/operatingsystems/23' }
      )
    );

    expect(screen.getByText(/Host group OS: RHEL 8/)).toBeInTheDocument();
    expect(
      screen.getByText(/does not have assigned host_init_config template/)
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Operating system' })).toHaveAttribute(
      'href',
      '/operatingsystems/23'
    );
  });

  it('for host group without OS', () => {
    render(
      osHelperText(
        null,
        [],
        1,
        [{ id: 1, inherited_operatingsystem_id: 23 }],
        {}
      )
    );

    expect(screen.getByText('No OS from host group')).toBeInTheDocument();
  });

  it('no OS or host group', () => {
    expect(osHelperText()).toEqual('');
  });
});
