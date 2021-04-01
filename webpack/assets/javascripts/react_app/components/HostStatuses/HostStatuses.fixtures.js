import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import { HOST_STATUSES_KEY } from './HostStatusesConstants';

export const store = Immutable({
  API: {
    [HOST_STATUSES_KEY]: {
      response: {
        results: [
          {
            name: 'Status Name',
            description: 'Description of the status',
            ok_total_path: '/hosts?search=status+%3D+ok',
            ok_owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+ok',
            warn_total_path: '/hosts?search=status+%3D+warn',
            warn_owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+warn',
            error_total_path: '/hosts?search=status+%3D+error',
            error_owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+error',
            details: [
              {
                label: 'OK',
                global_status: 0,
                total: 3,
                owned: 1,
                total_path: '/hosts?search=status+%3D+ok',
                owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+ok'
              },
              {
                label: 'Warning',
                global_status: 1,
                total: 7,
                owned: 2,
                total_path: '/hosts?search=status+%3D+warn',
                owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+warn'
              },
              {
                label: 'Error',
                global_status: 2,
                total: 5,
                owned: 0,
                total_path: '/hosts?search=status+%3D+error',
                owned_path: '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+error'
              }
            ]
          }
        ]
      },
      status: STATUS.RESOLVED,
    },
  },
});
