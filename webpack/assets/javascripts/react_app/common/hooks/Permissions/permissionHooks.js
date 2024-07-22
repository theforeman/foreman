import { useForemanPermissions } from '../../../Root/Context/ForemanContext';

/**
 * Custom hook to check whether a user is granted an array of permissions.
 *
 * @param requiredPermissions An array of permission names.
 * @returns {boolean} Indicates whether the current user is granted the given permissions.
 */
export const usePermissions = (requiredPermissions = []) => {
  const userPermissions = useForemanPermissions();
  return requiredPermissions.every(permission =>
    userPermissions.has(permission)
  );
};
