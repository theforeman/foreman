import PropTypes from 'prop-types';

export const hostDataProptypes = {
  hostData: PropTypes.shape({
    architecture_name: PropTypes.string,
    created_at: PropTypes.string,
    domain_name: PropTypes.string,
    ip: PropTypes.string,
    ip6: PropTypes.string,
    location_name: PropTypes.string,
    mac: PropTypes.string,
    operatingsystem_name: PropTypes.string,
    organization_name: PropTypes.string,
  }),
};

export const hostDataDefaultValues = {
  hostData: {
    architecture_name: '',
    created_at: '',
    domain_name: '',
    ip: '',
    ip6: '',
    location_name: '',
    mac: '',
    operatingsystem_name: '',
    organization_name: '',
  },
};
