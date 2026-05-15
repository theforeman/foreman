import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { createMemoryHistory } from 'history';
import { Router } from 'react-router-dom';
import { SearchIcon } from '@patternfly/react-icons';
import { ResourceLoadFailedEmptyState } from './index';
import { rtlHelpers } from '../../../common/rtlTestHelpers';
import { usePermissions } from '../../../common/hooks/Permissions/permissionHooks';

jest.mock('../../../common/hooks/Permissions/permissionHooks');

const renderComponent = (props, history = createMemoryHistory()) => {
  const defaultProps = {
    resourceLabel: 'hardware model',
    resourceId: 42,
    primaryAction: {
      label: 'Back to list',
      url: '/models',
    },
  };

  return {
    history,
    ...rtlHelpers.renderWithStore(
      <Router history={history}>
        <ResourceLoadFailedEmptyState {...defaultProps} {...props} />
      </Router>
    ),
  };
};

const permissionsIntro =
  /Accessing this page requires the following permissions/;

describe('ResourceLoadFailedEmptyState', () => {
  beforeEach(() => {
    usePermissions.mockReturnValue(true);
  });

  describe('failure messaging', () => {
    it('renders unknown failure messaging when view permissions are not provided', () => {
      renderComponent();

      expect(
        screen.getByRole('heading', {
          name: 'Unable to load hardware model',
          level: 5,
        })
      ).toBeInTheDocument();
      expect(
        screen.getByText('The hardware model with id 42 could not be loaded.')
      ).toBeInTheDocument();
      expect(screen.queryByText(permissionsIntro)).not.toBeInTheDocument();
    });

    it('renders unknown failure messaging without a resource id', () => {
      renderComponent({ resourceId: null });

      expect(
        screen.getByText('The hardware model could not be loaded.')
      ).toBeInTheDocument();
    });

    it('renders not-found messaging when the user can view the resource', () => {
      renderComponent({ viewPermissions: ['view_models'] });

      expect(
        screen.getByText(
          'The hardware model with id 42 could not be found. It may have been deleted or may not be available in your current organization or location scope.'
        )
      ).toBeInTheDocument();
    });

    it('renders not-found messaging without a resource id', () => {
      renderComponent({ viewPermissions: ['view_models'], resourceId: null });

      expect(
        screen.getByText(
          'The hardware model could not be found. It may have been deleted or may not be available in your current organization or location scope.'
        )
      ).toBeInTheDocument();
    });

    it('renders permission-denied messaging when view permissions are missing', () => {
      usePermissions.mockReturnValue(false);

      renderComponent({ viewPermissions: ['view_models'] });

      expect(
        screen.getByRole('heading', { name: 'Permission denied', level: 5 })
      ).toBeInTheDocument();
      expect(
        screen.getByText(
          /You do not have permission to view the hardware model with id 42/
        )
      ).toBeInTheDocument();
    });

    it('renders permission-denied messaging without a resource id', () => {
      usePermissions.mockReturnValue(false);

      renderComponent({
        viewPermissions: ['view_models'],
        resourceId: null,
      });

      expect(
        screen.getByText(/You do not have permission to view this hardware model/)
      ).toBeInTheDocument();
    });

    it('treats HTTP 403 as permission denied regardless of cached permissions', () => {
      usePermissions.mockReturnValue(true);

      renderComponent({ httpStatus: 403, viewPermissions: ['view_models'] });

      expect(
        screen.getByRole('heading', { name: 'Permission denied', level: 5 })
      ).toBeInTheDocument();
      expect(
        screen.getByText(
          /You do not have permission to view the hardware model with id 42/
        )
      ).toBeInTheDocument();
    });

    it('treats HTTP 404 as not found when view permissions are granted', () => {
      renderComponent({ httpStatus: 404, viewPermissions: ['view_models'] });

      expect(
        screen.getByText(
          'The hardware model with id 42 could not be found. It may have been deleted or may not be available in your current organization or location scope.'
        )
      ).toBeInTheDocument();
    });

    it('renders server error message when provided', () => {
      renderComponent({ errorMessage: 'Record not found' });

      expect(
        screen.getByText('Server returned: Record not found')
      ).toBeInTheDocument();
    });

    it('uses custom header and description when provided', () => {
      renderComponent({
        header: 'Custom header',
        description: 'Custom description',
        resourceId: null,
      });

      expect(
        screen.getByRole('heading', { name: 'Custom header', level: 5 })
      ).toBeInTheDocument();
      expect(screen.getByText('Custom description')).toBeInTheDocument();
      expect(
        screen.queryByText('The hardware model could not be loaded.')
      ).not.toBeInTheDocument();
    });
  });

  describe('permissions list', () => {
    it('renders required permissions when load did not fail for access', () => {
      renderComponent({
        viewPermissions: ['view_models'],
        requiredPermissions: ['view_models', 'edit_models'],
      });

      const paragraph = screen.getByText((_, element) => {
        return (
          element?.tagName === 'P' &&
          element.textContent?.includes('could not be found') &&
          element.textContent?.includes('view_models')
        );
      });
      expect(paragraph.textContent).toContain(
        'Accessing this page requires the following permissions'
      );
      expect(paragraph).toHaveTextContent('edit_models');
    });

    it('lists missing view permissions when access is denied', () => {
      usePermissions.mockReturnValue(false);

      renderComponent({
        viewPermissions: ['view_models'],
        requiredPermissions: ['view_models', 'edit_models'],
      });

      const paragraph = screen.getByText((_, element) => {
        return (
          element?.tagName === 'P' &&
          element.textContent?.match(permissionsIntro) &&
          element.textContent?.includes('view_models')
        );
      });
      expect(paragraph).toHaveTextContent('view_models');
      expect(paragraph).not.toHaveTextContent('edit_models');
    });

    it('falls back to requiredPermissions on HTTP 403 when view permissions are granted in cache', () => {
      usePermissions.mockReturnValue(true);

      renderComponent({
        httpStatus: 403,
        viewPermissions: ['test_permission_one'],
        requiredPermissions: ['view_models', 'edit_models'],
      });

      expect(screen.getByText(permissionsIntro)).toBeInTheDocument();
      expect(screen.getByText('view_models')).toBeInTheDocument();
      expect(screen.getByText('edit_models')).toBeInTheDocument();
    });

    it('does not render a permissions list when none are configured', () => {
      usePermissions.mockReturnValue(false);

      renderComponent({
        viewPermissions: [],
        requiredPermissions: null,
      });

      expect(screen.queryByText(permissionsIntro)).not.toBeInTheDocument();
    });
  });

  describe('presentation', () => {
    it('renders a custom icon when provided', () => {
      usePermissions.mockReturnValue(false);

      renderComponent({
        viewPermissions: ['view_models'],
        icon: <SearchIcon data-testid="custom-icon" />,
      });

      expect(screen.getByTestId('custom-icon')).toBeInTheDocument();
      expect(screen.queryByRole('heading', { name: 'Permission denied' })).toBeInTheDocument();
    });
  });

  describe('footer actions', () => {
    it('renders primary and back footer actions by default', () => {
      renderComponent();

      expect(
        screen.getByRole('button', { name: 'Back to list' })
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Return to the previous page' })
      ).toBeInTheDocument();
    });

    it('navigates using primary and secondary action urls', () => {
      const history = createMemoryHistory();
      const pushSpy = jest.spyOn(history, 'push');

      renderComponent(
        {
          secondaryActions: [
            {
              label: 'Create new',
              url: '/models/new',
            },
          ],
        },
        history
      );

      fireEvent.click(screen.getByRole('button', { name: 'Back to list' }));
      expect(pushSpy).toHaveBeenCalledWith('/models');

      fireEvent.click(screen.getByRole('button', { name: 'Create new' }));
      expect(pushSpy).toHaveBeenCalledWith('/models/new');
    });

    it('invokes primaryAction onClick when url is not provided', () => {
      const onClick = jest.fn();

      renderComponent({
        primaryAction: {
          label: 'Retry',
          onClick,
        },
      });

      fireEvent.click(screen.getByRole('button', { name: 'Retry' }));
      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('navigates back when the back button is clicked', () => {
      const history = createMemoryHistory();
      const goBackSpy = jest.spyOn(history, 'goBack');

      renderComponent({}, history);

      fireEvent.click(
        screen.getByRole('button', { name: 'Return to the previous page' })
      );
      expect(goBackSpy).toHaveBeenCalledTimes(1);
    });

    it('can hide the back button', () => {
      renderComponent({ showBackButton: false });

      expect(
        screen.queryByRole('button', { name: 'Return to the previous page' })
      ).not.toBeInTheDocument();
    });
  });
});
