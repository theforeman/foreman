import { useForemanPermissions } from '../../../Root/Context/ForemanContext';

/**
 * Custom hook to check whether a user is granted a **single** permission.
 *
 * Use {@link usePermissions} to check against multiple permissions.
 * @param requiredPermission {string} The name of a permission.
 * @returns {boolean} Indicates whether the current user is granted the given permission.
 */
export const usePermission = (requiredPermission = '') =>
  useForemanPermissions().has(requiredPermission);

/**
 * Custom hook to check whether a user is granted **multiple** permissions.
 *
 * Use {@link usePermission} to check against a single permission.
 * @param requiredPermissions An array of permission names.
 * @returns {boolean} Indicates whether the current user is granted the given permissions.
 */
export const usePermissions = (requiredPermissions = []) => {
  const userPermissions = useForemanPermissions();
  return requiredPermissions.every(permission =>
    userPermissions.has(permission)
  );
};
