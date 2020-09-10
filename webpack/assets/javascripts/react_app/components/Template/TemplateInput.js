import React from 'react';
import PropTypes from 'prop-types';
import DateTime from '../common/forms/DateTime/DateTime';
import Autocomplete from './Inputs/AutoComplete';

const TemplateInput = ({
  data: {
    label,
    resourceType,
    id,
    description,
    required,
    initialError,
    type,
    url,
    supportedTypes,
    template,
    value,
  },
}) => {
  const [plain, search, date] = supportedTypes;

  switch (type) {
    case plain:
      return null;
    case search:
      return (
        <Autocomplete
          label={label}
          id={id}
          isRequired={required}
          info={description}
          initialError={initialError}
          resourceType={resourceType}
          url={url}
          template={template}
          searchQuery={value}
        />
      );
    case date:
      return (
        <DateTime
          label={label}
          id={id}
          isRequired={required}
          info={description || 'Format is yyyy-mm-dd HH-mm-ss'}
          initialError={initialError}
          inputProps={{
            name: `${template}[input_values][${id}][value]`,
          }}
          hideValue={!value.length}
          value={value || undefined}
        />
      );
    default:
      return null;
  }
};

TemplateInput.propTypes = {
  data: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    type: PropTypes.string,
    url: PropTypes.string,
    resourceType: PropTypes.string,
    initialError: PropTypes.string,
    label: PropTypes.string.isRequired,
    description: PropTypes.string,
    required: PropTypes.bool,
    supportedTypes: PropTypes.arrayOf(PropTypes.string).isRequired,
    template: PropTypes.string.isRequired,
    value: PropTypes.string,
  }),
};

TemplateInput.defaultProps = {
  data: PropTypes.shape({
    url: null,
    useKeyShortcuts: false,
    resourceType: null,
    initialError: null,
    description: null,
    required: false,
    value: undefined,
  }),
};

export default TemplateInput;
