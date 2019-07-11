import React, { useEffect } from 'react';

const ResourceErrors = ({ resolveResourceErrors, resourceErrors }) => {
  useEffect(() => {
    resolveResourceErrors(resourceErrors);
  });

  return null;
};

export default ResourceErrors;
