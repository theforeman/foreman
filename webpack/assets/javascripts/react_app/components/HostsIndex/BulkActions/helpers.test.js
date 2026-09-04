import { buildBulkRequestBody, bulkErrorToastParams } from './helpers';

jest.mock('../../../common/I18n');

describe('BulkActions helpers', () => {
  describe('bulkErrorToastParams', () => {
    it('uses API error details from the response', () => {
      const toast = bulkErrorToastParams(
        {
          response: {
            data: {
              error: {
                message: 'Some hosts failed',
                failed_host_ids: [1, 2],
              },
            },
          },
        },
        'BULK_ACTION_KEY'
      );

      expect(toast).toMatchObject({
        type: 'danger',
        message: 'Some hosts failed',
      });
      expect(toast.link.children).toBe('Failed hosts');
      expect(toast.link.href).toContain('/new/hosts');
      expect(toast.link.href).toContain('search=');
    });

    it('uses the error message when no response exists', () => {
      const toast = bulkErrorToastParams(
        { message: 'Network Error' },
        'BULK_ACTION_KEY'
      );

      expect(toast).toMatchObject({
        type: 'danger',
        message: 'Network Error',
      });
      expect(toast.link).toBeUndefined();
    });

    it('uses a response error string as the message', () => {
      const toast = bulkErrorToastParams(
        {
          response: {
            data: {
              error: 'Bulk action failed',
            },
          },
        },
        'BULK_ACTION_KEY'
      );

      expect(toast).toMatchObject({
        type: 'danger',
        message: 'Bulk action failed',
      });
      expect(toast.link).toBeUndefined();
    });

    it('falls back to a generic message when no usable message exists', () => {
      const toast = bulkErrorToastParams({}, 'BULK_ACTION_KEY');

      expect(toast).toMatchObject({
        type: 'danger',
        message: 'Unexpected error occurred.',
      });
      expect(toast.link).toBeUndefined();
    });

    it('appends unique per-host errors from failed_hosts', () => {
      const toast = bulkErrorToastParams(
        {
          response: {
            data: {
              error: {
                message: 'Failed to set parameter for 1 host',
                failed_host_ids: [1],
                failed_hosts: [
                  {
                    id: 1,
                    error: 'You do not have permission to edit this parameter',
                  },
                ],
              },
            },
          },
        },
        'BULK_ACTION_KEY'
      );

      expect(toast).toMatchObject({
        type: 'danger',
        message:
          'Failed to set parameter for 1 host You do not have permission to edit this parameter',
      });
      expect(toast.link.children).toBe('Failed hosts');
    });

    it('keeps failed hosts link when response error has no message', () => {
      const toast = bulkErrorToastParams(
        {
          response: {
            data: {
              error: {
                failed_host_ids: [1, 2],
              },
            },
          },
        },
        'BULK_ACTION_KEY'
      );

      expect(toast).toMatchObject({
        type: 'danger',
        message: 'Unexpected error occurred.',
      });
      expect(toast.link.children).toBe('Failed hosts');
    });
  });

  describe('buildBulkRequestBody', () => {
    it('builds an included search from fetchBulkParams', () => {
      const body = buildBulkRequestBody({
        fetchBulkParams: () => 'id ^ (1,2,3)',
        reboot: true,
      });

      expect(body).toEqual({
        included: {
          search: 'id ^ (1,2,3)',
        },
        reboot: true,
      });
    });

    it('adds taxonomy params when present', () => {
      const body = buildBulkRequestBody({
        fetchBulkParams: () => 'id ^ (1,2,3)',
        organizationId: 1,
        locationId: 2,
      });

      expect(body).toMatchObject({
        included: {
          search: 'id ^ (1,2,3)',
        },
        organization_id: 1,
        location_id: 2,
      });
    });

    it('uses includedSearch instead of calling fetchBulkParams', () => {
      const fetchBulkParams = jest.fn();

      const body = buildBulkRequestBody({
        fetchBulkParams,
        includedSearch: 'name ~ test',
      });

      expect(body).toEqual({
        included: {
          search: 'name ~ test',
        },
      });
      expect(fetchBulkParams).not.toHaveBeenCalled();
    });
  });
});
