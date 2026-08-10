import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ExpansiveView from '../ExpansiveView';
import { AuditRecord } from './AuditsList.fixtures';

const {
  action_display_name: actionDisplayName,
  details,
  comment,
  audited_changes_with_id_to_label: auditedChangesWithIdToLabel,
  audited_changes: auditedChanges,
} = AuditRecord;

const defaultProps = {
  actionDisplayName,
  details,
  comment,
  auditedChanges,
  auditedChangesWithIdToLabel,
};

describe('ExpansiveView', () => {
  it('renders audit change names and values', () => {
    render(<ExpansiveView {...defaultProps} />);

    expect(screen.getByText('Name')).toBeInTheDocument();
    expect(screen.getByText('temp1')).toBeInTheDocument();
    expect(screen.getByText('temp2')).toBeInTheDocument();
  });

  it('renders template diff when template changed', () => {
    render(<ExpansiveView {...defaultProps} />);

    expect(screen.getByRole('table', { name: 'diff-table' })).toBeInTheDocument();
  });

  it('does not render template diff when template values are equal', () => {
    const sameTemplateProps = {
      ...defaultProps,
      auditedChanges: { template: ['<h1>Same</h1>', '<h1>Same</h1>'] },
    };

    render(<ExpansiveView {...sameTemplateProps} />);

    expect(screen.queryByRole('table', { name: 'diff-table' })).not.toBeInTheDocument();
  });

  it('renders comment section when comment is provided', () => {
    render(<ExpansiveView {...defaultProps} />);

    expect(screen.getByText('Comments')).toBeInTheDocument();
    expect(screen.getByText('This is just test audit record')).toBeInTheDocument();
  });

  it('does not render comment section when comment is undefined', () => {
    render(<ExpansiveView {...defaultProps} comment={undefined} />);

    expect(screen.queryByText('Comments')).not.toBeInTheDocument();
  });

  it('renders details list for add action', () => {
    const addProps = {
      ...defaultProps,
      actionDisplayName: 'add',
      details: ['Added test object'],
      auditedChangesWithIdToLabel: [],
    };

    render(<ExpansiveView {...addProps} />);

    expect(screen.getByText('Added test object')).toBeInTheDocument();
  });

  it('renders details list for remove action', () => {
    const removeProps = {
      ...defaultProps,
      actionDisplayName: 'remove',
      details: ['Removed test object'],
      auditedChangesWithIdToLabel: [],
    };

    render(<ExpansiveView {...removeProps} />);

    expect(screen.getByText('Removed test object')).toBeInTheDocument();
  });

  it('renders nothing when no changes, no details, and no comment', () => {
    const emptyProps = {
      actionDisplayName: 'update',
      auditedChanges: {},
      auditedChangesWithIdToLabel: [],
      details: [],
    };
    const { container } = render(<ExpansiveView {...emptyProps} />);

    expect(container.querySelector('table')).not.toBeInTheDocument();
    expect(screen.queryByText('Comments')).not.toBeInTheDocument();
  });
});
