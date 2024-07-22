import React from 'react';
import '@testing-library/jest-dom'
import {render} from '@testing-library/react';
import Permitted from "./Permitted";
import {
  invalidPermissionsArray,
  invalidPermissionString,
  noPermissionPropWarning,
  permissionsArray,
  permissionString,
  requiredPermissionsEmptyWarning,
  requiredPermissionsTypeWarning,
  testString,
  unPermittedTestString,
} from './Permitted.fixtures'


describe('Permitted', () => {

  describe('component', () => {

    it('renders the component if a single permission is required', () => {

      const {queryByText} = render(<Permitted requiredPermissions={[permissionString]}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).toBeInTheDocument()
    });
    it('renders the component if multiple permissions are required', () => {

      const {queryByText} = render(<Permitted requiredPermissions={permissionsArray}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).toBeInTheDocument()
    });
    it('doesn\'t render the component if a single permission is not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermissions={[invalidPermissionString]}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).not.toBeInTheDocument()
    });
    it('doesn\'t render the component if multiple permissions are not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermissions={invalidPermissionsArray}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).not.toBeInTheDocument()
    });
    it('renders the unpermittedComponent if a permission is not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermissions={[invalidPermissionString]}
        unpermittedComponent={unPermittedTestString}>{testString}</Permitted>);

      const testElement = queryByText(unPermittedTestString)
      expect(testElement).toBeInTheDocument()
    });

    it('renders the PermissionDenied component if a permission is not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermissions={[invalidPermissionString]}>{testString}</Permitted>);

      const testElement = queryByText("Permission Denied")
      expect(testElement).toBeInTheDocument()
    });
  })

  describe('warns', () => {

    let consoleSpy;

    beforeEach(() => {
      consoleSpy = jest.spyOn(global.console, 'error').mockImplementation(() => {})
    })
    afterEach(() => {
      jest.clearAllMocks()
    })

    it('when no permission prop is passed', () => {

      render(<Permitted>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(noPermissionPropWarning)

    });

    it('when requiredPermissions is an empty array', () => {

      render(<Permitted requiredPermissions={[]}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionsEmptyWarning)

    });

    it('when requiredPermissions is the wrong type', () => {

      render(<Permitted requiredPermissions={""}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionsTypeWarning)

    });

  })

});
