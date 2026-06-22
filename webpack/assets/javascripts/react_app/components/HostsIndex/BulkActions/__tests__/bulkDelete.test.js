import { bulkDeleteHosts } from '../bulkDelete';
import { openConfirmModal } from '../../../ConfirmModal';
import { APIActions } from '../../../../redux/API';
import { visit } from '../../../../common/helpers';

jest.mock('../../../ConfirmModal', () => ({
  openConfirmModal: jest.fn(payload => ({
    type: 'OPEN_CONFIRM_MODAL',
    payload,
  })),
}));

jest.mock('../../../../redux/API', () => ({
  APIActions: {
    delete: jest.fn(params => ({
      type: 'API_DELETE',
      params,
    })),
  },
}));

jest.mock('../../../../common/helpers', () => ({
  foremanUrl: jest.fn(path => path),
  visit: jest.fn(),
}));

describe('bulkDeleteHosts', () => {
  const dispatch = jest.fn(action => {
    if (typeof action === 'function') {
      return action(dispatch);
    }
    return action;
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  const bulkParams = 'id ^ (1,2,3)';
  const organizationId = 1;
  const locationId = 2;
  const selectedCount = 3;
  const destroyVmOnHostDelete = true;

  it('dispatches openConfirmModal with correct parameters', () => {
    bulkDeleteHosts({
      bulkParams,
      organizationId,
      locationId,
      selectedCount,
      destroyVmOnHostDelete,
    })(dispatch);

    expect(openConfirmModal).toHaveBeenCalledTimes(1);
    const modalPayload = openConfirmModal.mock.calls[0][0];

    expect(modalPayload.isWarning).toBe(true);
    expect(modalPayload.isDireWarning).toBe(true);
    expect(modalPayload.id).toBe('bulk-delete-hosts-modal');
    expect(modalPayload.confirmButtonText).toBe('Delete');
    expect(typeof modalPayload.onConfirm).toBe('function');
  });

  describe('onConfirm callback', () => {
    it('calls visit with /new/hosts when onDeleteSuccess is not provided', () => {
      bulkDeleteHosts({
        bulkParams,
        organizationId,
        locationId,
        selectedCount,
        destroyVmOnHostDelete,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      expect(APIActions.delete).toHaveBeenCalledTimes(1);
      const deleteParams = APIActions.delete.mock.calls[0][0];
      const requestUrl = new URL(deleteParams.url, 'https://example.test');

      expect(requestUrl.pathname).toBe('/api/v2/hosts/bulk');
      expect(requestUrl.searchParams.get('search')).toBe(bulkParams);
      expect(requestUrl.searchParams.get('organization_id')).toBe(
        String(organizationId)
      );
      expect(requestUrl.searchParams.get('location_id')).toBe(
        String(locationId)
      );
      expect(deleteParams.key).toBe('BULK-HOSTS-DELETE');
      expect(typeof deleteParams.successToast).toBe('function');
      expect(typeof deleteParams.errorToast).toBe('function');
      expect(typeof deleteParams.handleSuccess).toBe('function');

      deleteParams.handleSuccess();
      expect(visit).toHaveBeenCalledWith('/new/hosts');
    });

    it('calls onDeleteSuccess callback when provided instead of visit', () => {
      const onDeleteSuccess = jest.fn();

      bulkDeleteHosts({
        bulkParams,
        organizationId,
        locationId,
        selectedCount,
        destroyVmOnHostDelete,
        onDeleteSuccess,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      deleteParams.handleSuccess();

      expect(onDeleteSuccess).toHaveBeenCalledTimes(1);
      expect(visit).not.toHaveBeenCalled();
    });
  });

  describe('successToast', () => {
    it('returns formatted success message with host count', () => {
      bulkDeleteHosts({
        bulkParams,
        organizationId,
        locationId,
        selectedCount,
        destroyVmOnHostDelete,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      const toastMessage = deleteParams.successToast();

      expect(toastMessage).toContain(String(selectedCount));
    });
  });

  describe('errorToast', () => {
    it('returns error message from response', () => {
      bulkDeleteHosts({
        bulkParams,
        organizationId,
        locationId,
        selectedCount,
        destroyVmOnHostDelete,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      const errorMessage = 'Bulk delete failed';
      const toastMessage = deleteParams.errorToast({ message: errorMessage });

      expect(toastMessage).toBe(errorMessage);
    });
  });
});
