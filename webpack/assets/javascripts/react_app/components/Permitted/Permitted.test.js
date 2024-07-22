import React from 'react';
import '@testing-library/jest-dom'
import {render} from '@testing-library/react';
import Permitted from "./Permitted";
import {
  invalidPermissionsArray,
  invalidPermissionString,
  noPermissionPropWarning,
  permissionsArray,
  permissionsSet,
  permissionString,
  requiredPermissionEmptyWarning,
  requiredPermissionsEmptyWarning,
  requiredPermissionsTypeWarning,
  requiredPermissionTypeWarning,
  testString,
  unPermittedTestString,
} from './Permitted.fixtures'
import * as foremanContextHooks from '../../Root/Context/ForemanContext'


describe('Permitted', () => {

  describe('component', () => {
    beforeEach(() => {
      jest.spyOn(foremanContextHooks, 'useForemanPermissions').mockImplementation(() => permissionsSet);
    })
    afterEach(() => {
      jest.clearAllMocks()
    })

    it('renders the component if a single permission is required', () => {

      const {queryByText} = render(<Permitted requiredPermission={permissionString}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).toBeInTheDocument()
    });
    it('renders the component if a multiple permissions are required', () => {

      const {queryByText} = render(<Permitted requiredPermissions={permissionsArray}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).toBeInTheDocument()
    });
    it('doesn\'t render the component if a single permission is not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermission={invalidPermissionString}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).not.toBeInTheDocument()
    });
    it('doesn\'t render the component if a multiple permissions are not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermissions={invalidPermissionsArray}>{testString}</Permitted>);

      const testElement = queryByText(testString)
      expect(testElement).not.toBeInTheDocument()
    });
    it('renders the unpermittedComponent if a permission is not met', () => {

      const {queryByText} = render(<Permitted
        requiredPermission={invalidPermissionString}
        unpermittedComponent={unPermittedTestString}>{testString}</Permitted>);

      const testElement = queryByText(unPermittedTestString)
      expect(testElement).toBeInTheDocument()
    });
  })

  describe('warns', () => {

    let consoleSpy;

    beforeEach(() => {
      consoleSpy = jest.spyOn(global.console, 'error')
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

    it('when requiredPermission is an empty string', () => {

      render(<Permitted requiredPermission={""}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionEmptyWarning)

    });

    it('when requiredPermissions is an empty array', () => {

      render(<Permitted requiredPermissions={[]}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionsEmptyWarning)

    });

    it('when requiredPermission is the wrong type', () => {

      render(<Permitted requiredPermission={[]}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionTypeWarning)

    });

    it('when requiredPermissions is the wrong type', () => {

      render(<Permitted requiredPermissions={""}>{testString}</Permitted>);

      expect(consoleSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledTimes(1)
      expect(consoleSpy).toHaveBeenCalledWith(requiredPermissionsTypeWarning)

    });

  })

});
