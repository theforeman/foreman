import '@testing-library/jest-dom'
import {usePermissions} from "./permissionHooks";
import {
  invalidPermissionsArray,
  validPermissionsArray
} from "./permissionHooks.fixtures";


describe('permissionHooks', () => {

  describe('usePermissions', () => {
    it('should correctly evaluate multiple valid permissions', () => {
      const result = usePermissions(validPermissionsArray)
      expect(result).toBe(true)
    })
    it('should correctly evaluate multiple invalid permissions', () => {
      const result = usePermissions(invalidPermissionsArray)
      expect(result).toBe(false)
    })
  });
})
