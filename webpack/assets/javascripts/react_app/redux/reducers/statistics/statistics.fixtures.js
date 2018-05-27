import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  charts: Immutable({}),
});

export const request = {
  id: 'operatingsystem',
  title: 'OS Distribution',
  url: 'statistics/operatingsystem',
  search: '/hosts?search=os_title=~VAL~',
};

export const response = {
  id: 'operatingsystem',
  data: [['RedHat 3', 2]],
};

export const error = 'some error happened';

export const stateBeforeResponse = Immutable({
  charts: {
    [request.id]: request,
  },
});
