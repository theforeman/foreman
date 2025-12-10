export const alerts = { error: 'some-error' };
export const caption = 'some caption';
export const logoSrc = '/some-logo';
export const token = 'some token';
export const oidcProviders = [
  { id: 1, name: 'Google', loginUrl: '/users/auth/oidc_1' },
  { id: 2, name: 'Keycloak', loginUrl: '/users/auth/oidc_2' },
];

export const props = {
  alerts,
  caption,
  logoSrc,
  token,
  oidcProviders: [],
};

export const propsWithOidc = {
  alerts,
  caption,
  logoSrc,
  token,
  oidcProviders,
};
