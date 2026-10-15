import { buildHost, deleteHost } from '../actions';
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
    put: jest.fn(params => ({
      type: 'API_PUT',
      params,
    })),
  },
}));

jest.mock('../../../../common/helpers', () => ({
  foremanUrl: jest.fn(path => path),
  visit: jest.fn(),
}));

describe('deleteHost', () => {
  const dispatch = jest.fn(action => {
    if (typeof action === 'function') {
      return action(dispatch);
    }
    return action;
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  const hostName = 'test-host.example.com';
  const computeId = 123;
  const destroyVmOnHostDelete = true;

  it('dispatches openConfirmModal with correct parameters', () => {
    deleteHost(hostName, computeId, destroyVmOnHostDelete, {
      hostsIndexUrl: '/hosts',
    })(dispatch);

    expect(openConfirmModal).toHaveBeenCalledTimes(1);
    const modalPayload = openConfirmModal.mock.calls[0][0];

    expect(modalPayload.isWarning).toBe(true);
    expect(modalPayload.confirmButtonText).toBe('Delete');
    expect(typeof modalPayload.onConfirm).toBe('function');
  });

  describe('onConfirm callback', () => {
    it('calls visit with hostsIndexUrl when onDeleteSuccess is not provided', () => {
      const hostsIndexUrl = '/new/hosts';

      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        hostsIndexUrl,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      expect(APIActions.delete).toHaveBeenCalledTimes(1);
      const deleteParams = APIActions.delete.mock.calls[0][0];

      expect(deleteParams.url).toBe(`/api/hosts/${hostName}`);
      expect(deleteParams.key).toBe(`${hostName}-DELETE`);
      expect(typeof deleteParams.successToast).toBe('function');
      expect(typeof deleteParams.errorToast).toBe('function');
      expect(typeof deleteParams.handleSuccess).toBe('function');

      deleteParams.handleSuccess();
      expect(visit).toHaveBeenCalledWith(hostsIndexUrl);
    });

    it('calls onDeleteSuccess callback when provided instead of visit', () => {
      const onDeleteSuccess = jest.fn();

      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        onDeleteSuccess,
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      deleteParams.handleSuccess();

      expect(onDeleteSuccess).toHaveBeenCalledTimes(1);
      expect(visit).not.toHaveBeenCalled();
    });

    it('prefers onDeleteSuccess over hostsIndexUrl when both are provided', () => {
      const onDeleteSuccess = jest.fn();
      const hostsIndexUrl = '/hosts';

      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        hostsIndexUrl,
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
    it('returns formatted success message with host name', () => {
      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        hostsIndexUrl: '/hosts',
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      const toastMessage = deleteParams.successToast();

      expect(toastMessage).toContain(hostName);
    });
  });

  describe('errorToast', () => {
    it('returns error message from response', () => {
      deleteHost(hostName, computeId, destroyVmOnHostDelete, {
        hostsIndexUrl: '/hosts',
      })(dispatch);

      const modalPayload = openConfirmModal.mock.calls[0][0];
      modalPayload.onConfirm();

      const deleteParams = APIActions.delete.mock.calls[0][0];
      const errorMessage = 'Something went wrong';
      const toastMessage = deleteParams.errorToast({ message: errorMessage });

      expect(toastMessage).toBe(errorMessage);
    });
  });
});

describe('buildHost', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('uses the server error message when a build request fails', () => {
    const dispatch = jest.fn();
    const serverMessage = 'Boot files missing, download boot files for CentOS 10';

    buildHost('host-id')(dispatch);
    const { errorToast } = APIActions.put.mock.calls[0][0];

    expect(
      errorToast({
        message: 'Request failed with status code 422',
        response: { data: { message: serverMessage } },
      })
    ).toBe(serverMessage);
  });

  it('falls back to the server errors array when there is no message', () => {
    const dispatch = jest.fn();
    const serverMessage = 'Boot files missing, download boot files for CentOS 10';

    buildHost('host-id')(dispatch);
    const { errorToast } = APIActions.put.mock.calls[0][0];

    expect(
      errorToast({
        message: 'Request failed with status code 422',
        response: { data: { errors: [serverMessage] } },
      })
    ).toBe(serverMessage);
  });
});
