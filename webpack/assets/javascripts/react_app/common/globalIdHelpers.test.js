import {
  decode,
  getId,
  decodeModelId,
  decodeId,
  encodeId,
} from './globalIdHelpers';

const HOSTS = [
  {id: 'MDE6SG9zdC0x', realId: 1},
  {id: 'MDE6SG9zdC0y', realId: 2},
  {id: 'MDE6SG9zdC0z', realId: 3},
];

const HOSTGROUPS = [
  {id: 'MDE6SG9zdGdyb3VwLTE=', realId: 1 },
  {id: 'MDE6SG9zdGdyb3VwLTI=', realId: 2 },
  {id: 'MDE6SG9zdGdyb3VwLTM=', realId: 3 },
];

describe('decode', () => {
  it('decodes a global id into a list of its parts', () => {
    expect(decode('MDE6SG9zdC0z')).toEqual({ version: 1, type: 'Host', id: '3'});
  });
});

describe('getId', () => {
  it('retrieves id part of global id', () => {
    HOSTS.forEach(({id, realId}) => {
      expect(getId(id)).toEqual(`${realId}`);
    });

    expect(getId('MDE6Rm9yZW1hblRhc2tzOjpUYXNrLTAzZGY3NWVlLTJkNTMtNGY2Zi04ZjU0LWU3OGIyN2RiYzM0Nw==')).toEqual('03df75ee-2d53-4f6f-8f54-e78b27dbc347');
  });
});

describe('decodeModelId', () => {
  it('decodes ID from host models', () => {
    HOSTS.forEach((model) => {
      expect(decodeModelId(model)).toEqual(model.realId);
    });
  });

  it('decodes ID from hostgroup models', () => {
    HOSTGROUPS.forEach((model) => {
      expect(decodeModelId(model)).toEqual(model.realId);
    });
  });
});

describe('decodeModelId', () => {
  it('decodes host ID', () => {
    HOSTS.forEach(({id, realId}) => {
      expect(decodeId(id)).toEqual(realId);
    });
  });

  it('decodes hostgroup ID', () => {
    HOSTGROUPS.forEach(({id, realId}) => {
      expect(decodeId(id)).toEqual(realId);
    });
  });
});


describe('encodeId', () => {
  it('decodes host ID', () => {
    HOSTS.forEach(({id, realId}) => {
      expect(encodeId('Host', realId)).toEqual(id);
    });
  });

  it('decodes hostgroup ID', () => {
    HOSTGROUPS.forEach(({id, realId}) => {
      expect(encodeId('Hostgroup', realId)).toEqual(id);
    });
  });
});
