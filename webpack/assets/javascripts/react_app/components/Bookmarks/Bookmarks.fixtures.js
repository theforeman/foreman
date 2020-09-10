export const controller = 'hosts';
/* eslint-disable camelcase */
export const bookmarks = [
  {
    name: '1111',
    controller,
    query: 'abc',
    public: true,
    id: 52,
    owner_id: 1,
    owner_type: 'User',
  },
  {
    name: '1122',
    controller,
    query: 'abc',
    public: true,
    id: 54,
    owner_id: 1,
    owner_type: 'User',
  },
];

export const response = {
  data: {
    results: bookmarks,
  },
};

export const name = 'Joe.D';
export const search = 'name ~ my';
export const publik = false;
export const item = 'Bookmark';

export const submitResponse = {
  data: {
    name,
    query: search,
    controller,
    public: publik,
  },
  item,
};
