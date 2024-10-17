
export const testString = "Unambiguous test string"
export const unPermittedTestString = "Unambiguous unpermitted test string"
export const permissionString = "test_permission_one"
export const permissionsArray = [permissionString, "test_permission_two"]
export const permissionsSet = new Set(permissionsArray)
export const invalidPermissionString = "some_other_permission_one"
export const invalidPermissionsArray = [invalidPermissionString, "some_other_permission_two"]

// Console warnings
export const noPermissionPropWarning = "Warning: Failed prop type: One of the props [requiredPermission, requiredPermissions] must be set in Permitted.\n    in Permitted"
export const requiredPermissionEmptyWarning = "Warning: Failed prop type: requiredPermission can not be an empty string.\n    in Permitted"
export const requiredPermissionsEmptyWarning = "Warning: Failed prop type: requiredPermissions can not be an empty array.\n    in Permitted"
export const requiredPermissionTypeWarning = "Warning: Failed prop type: Invalid prop `requiredPermission` of type `array` supplied to `Permitted`, expected `string`."
export const requiredPermissionsTypeWarning = "Warning: Failed prop type: Invalid prop `requiredPermissions` of type `string` supplied to `Permitted`, expected `array`."
