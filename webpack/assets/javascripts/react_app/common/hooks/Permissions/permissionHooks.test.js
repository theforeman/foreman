import '@testing-library/jest-dom'
import {usePermission, usePermissions} from "./permissionHooks";
import {
  allPermissions,
  invalidPermission,
  invalidPermissionsArray,
  validPermission,
  validPermissionsArray
} from "./permissionHooks.fixtures";
import * as foremanContextHooks from '../../../Root/Context/ForemanContext'


describe('permissionHooks', () => {
  beforeEach(() => {
    jest.spyOn(foremanContextHooks, 'useForemanPermissions').mockImplementation(() => allPermissions)
  })
  afterEach(() => {
    jest.clearAllMocks()
  })

  describe('usePermission', () => {
    it('should correctly evaluate a valid permission', () => {
      const result = usePermission(validPermission)
      expect(result).toBe(true)
    })
    it("should correctly evaluate an invalid permission", () => {
      const result = usePermission(invalidPermission)
      expect(result).toBe(false)
    })
  })
  describe('usePermissions', () => {
    it('should correctly evaluate multiple valid permissions', () => {
      const result = usePermissions(validPermissionsArray)
      expect(result).toBe(true)
    })
    it('should correctly evaluate multiple invalid permissions', () => {
      const result = usePermission(invalidPermissionsArray)
      expect(result).toBe(false)
    })
  });
})
