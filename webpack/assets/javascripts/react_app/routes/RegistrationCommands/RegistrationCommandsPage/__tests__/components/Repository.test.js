import React, { useState } from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import userEvent from '@testing-library/user-event';

import Repository from '../../components/fields/Repository';
import { repositoryProps } from '../fixtures';

const defaultRepoEntry = {
  reference: 0,
  repository: '',
  gpgKeyUrl: '',
};

const renderRepository = (props = {}) => {
  const defaultProps = {
    ...repositoryProps,
    ...props,
  };

  return render(<Repository {...defaultProps} />);
};

const renderRepositoryWithState = (
  initialRepoData = [defaultRepoEntry],
  props = {}
) => {
  const Wrapper = () => {
    const [repoData, setRepoData] = useState(initialRepoData);

    return (
      <Repository
        repoData={repoData}
        handleRepoData={setRepoData}
        isLoading={false}
        {...props}
      />
    );
  };

  return render(<Wrapper />);
};

const openRepositoryModal = () => {
  userEvent.click(
    screen.getByRole('button', {
      name: /Add repositories for registration/,
    })
  );
};

describe('RegistrationCommandsPage fields - Repository', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders the repositories form group', () => {
    renderRepository();

    expect(screen.getByText('Repositories')).toBeInTheDocument();
    expect(
      screen.getByRole('button', {
        name: 'Add repositories for registration (0 set)',
      })
    ).toBeInTheDocument();
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('shows the repository count in the add button', () => {
    renderRepository({
      repoData: [
        { reference: 0, repository: 'http://rpm.example.com/', gpgKeyUrl: '' },
        { reference: 1, repository: '', gpgKeyUrl: 'http://example.com/key' },
      ],
    });

    expect(
      screen.getByRole('button', {
        name: 'Add repositories for registration (1 set)',
      })
    ).toBeInTheDocument();
  });

  it('shows the count for multiple configured repositories', () => {
    renderRepository({
      repoData: [
        { reference: 0, repository: 'http://rpm.example.com/', gpgKeyUrl: '' },
        {
          reference: 1,
          repository: 'http://deb.example.com/',
          gpgKeyUrl: '',
        },
      ],
    });

    expect(
      screen.getByRole('button', {
        name: 'Add repositories for registration (2 set)',
      })
    ).toBeInTheDocument();
  });

  it('opens the repository modal when the add button is clicked', () => {
    renderRepository();

    openRepositoryModal();

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText('Repository list')).toBeInTheDocument();
  });

  it('disables modal inputs when loading', () => {
    renderRepository({
      isLoading: true,
      repoData: [defaultRepoEntry],
    });

    openRepositoryModal();

    screen.getAllByRole('textbox').forEach(input => {
      expect(input).toBeDisabled();
    });
  });

  describe('RepositoryModal', () => {
    it('renders form fields and actions when open', () => {
      renderRepositoryWithState();

      openRepositoryModal();

      expect(screen.getByText('Repository')).toBeInTheDocument();
      expect(screen.getByText('Repository GPG key URL')).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Confirm' })
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Reset form' })
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Add repository' })
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Remove' })
      ).toBeInTheDocument();
    });

    it('adds a repository row when Add repository is clicked', () => {
      renderRepositoryWithState();

      openRepositoryModal();

      expect(screen.getAllByRole('textbox')).toHaveLength(2);

      userEvent.click(
        screen.getByRole('button', { name: 'Add repository' })
      );

      expect(screen.getAllByRole('textbox')).toHaveLength(4);
      expect(screen.getAllByRole('button', { name: 'Remove' })).toHaveLength(
        2
      );
    });

    it('removes a repository row when Remove is clicked', () => {
      renderRepositoryWithState([
        { reference: 0, repository: 'http://a.com/', gpgKeyUrl: '' },
        { reference: 1, repository: 'http://b.com/', gpgKeyUrl: '' },
      ]);

      openRepositoryModal();

      expect(screen.getAllByRole('button', { name: 'Remove' })).toHaveLength(
        2
      );

      userEvent.click(
        screen.getAllByRole('button', { name: 'Remove' })[0]
      );

      expect(screen.getAllByRole('button', { name: 'Remove' })).toHaveLength(
        1
      );
      expect(screen.getAllByRole('textbox')).toHaveLength(2);
    });

    it('updates repository input when typing', () => {
      renderRepositoryWithState();

      openRepositoryModal();

      const [repoInput] = screen.getAllByRole('textbox');

      userEvent.type(repoInput, 'http://rpm.example.com/');

      expect(repoInput).toHaveValue('http://rpm.example.com/');
    });

    it('clears repositories when Reset form is clicked', () => {
      renderRepositoryWithState([
        { reference: 0, repository: 'http://rpm.example.com/', gpgKeyUrl: '' },
      ]);

      openRepositoryModal();

      userEvent.click(
        screen.getByRole('button', { name: 'Reset form' })
      );

      expect(screen.getAllByRole('textbox')[0]).toHaveValue('');
      expect(screen.getAllByRole('textbox')[1]).toHaveValue('');
    });

    it('closes the modal and removes empty rows when Confirm is clicked', () => {
      renderRepositoryWithState([
        { reference: 0, repository: 'http://rpm.example.com/', gpgKeyUrl: '' },
      ]);

      openRepositoryModal();

      userEvent.click(
        screen.getByRole('button', { name: 'Add repository' })
      );
      userEvent.click(screen.getByRole('button', { name: 'Confirm' }));

      expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
      expect(
        screen.getByRole('button', {
          name: 'Add repositories for registration (1 set)',
        })
      ).toBeInTheDocument();
    });
  });
});
