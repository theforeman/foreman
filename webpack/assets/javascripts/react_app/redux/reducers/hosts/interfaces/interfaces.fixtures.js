import Immutable from 'seamless-immutable';

export const getInterfaceData = () => ({
  id: Math.floor(Math.random() * 100000000001),
  identifier: null,
  type: 'Nic::Managed',
  typeName: 'Interface',
  mac: null,
  ip: null,
  ip6: null,
  name: 'ida-michon',
  domain: null,
  primary: false,
  provision: false,
  managed: true,
  hasErrors: false,
});

export const defaultState = Immutable({
  interfaces: [
    {
      id: 47354668887600,
      identifier: null,
      type: 'Nic::Managed',
      typeName: 'Interface',
      mac: null,
      ip: null,
      ip6: null,
      name: 'ida-michon',
      domain: null,
      primary: true,
      provision: true,
      managed: true,
      hasErrors: false,
    },
  ],
  tableCssClasses: 'table table-bordered table-striped table-hover',
});
