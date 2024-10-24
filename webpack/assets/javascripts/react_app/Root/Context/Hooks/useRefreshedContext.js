import axios from 'axios';
import { useEffect, useState } from 'react';
import { useForemanSetContext } from '../ForemanContext';

/**
 * Custom hook that requests the up-to-date application context from the Foreman-backend and updates the ForemanContext accordingly.
 * Performs an API request to /api/v2/context.
 * @param {Array<string>} only An array of metadata fields to restrict the context update to.
 * @returns {{isLoading: boolean, isError: boolean, data: object, error: object, status: number}}
 */
const useRefreshedContext = (only = null) => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [responseData, setResponseData] = useState(null);
  const [isError, setIsError] = useState(false);
  const [status, setStatus] = useState(null);

  const setForemanContext = useForemanSetContext(responseData);

  const getContext = async () => {
    setIsLoading(true);
    setIsError(false);

    try {
      const response = await axios.get('/api/v2/context', {
        params: { only },
      });
      setStatus(response.status);
      setResponseData(response.data);
    } catch (err) {
      setError(err);
      setIsError(true);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getContext();
    return () => {
      setIsLoading(false);
    };
  }, []);

  setForemanContext(context => {
    if (!isLoading && status !== null) {
      // eslint-disable-next-line no-unused-vars
      for (const property of only || Object.keys(context.metadata)) {
        if (property !== 'permissions') {
          context.metadata[property] = responseData.metadata[property];
        } else {
          context.metadata.permissions = new Set(
            responseData.metadata.permissions
          );
        }
      }
    }
    return context;
  });

  return {
    isLoading,
    isError,
    error,
    data: responseData,
    status,
  };
};

export default useRefreshedContext;
