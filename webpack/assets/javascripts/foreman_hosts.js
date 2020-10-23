import { uniq, set } from 'lodash';
import * as table from './hosts/tableCheckboxes';

export default {
  table,
  registerPluginAttributes,
  getAttributesToPost,
  copyRegistrationCommand,
  checkPXELoaderCompatibility,
  pxeCompatibility,
};

const pluginEditAttributes = {
  architecture: [],
  os: [],
  medium: [],
  image: [],
};

export function registerPluginAttributes(componentType, attributes) {
  if (pluginEditAttributes[componentType] !== undefined) {
    const combinedAttributes = pluginEditAttributes[componentType].concat(
      attributes
    );
    pluginEditAttributes[componentType] = uniq(combinedAttributes);
  }
}

export function getAttributesToPost(componentType) {
  const defaultAttributes = {
    architecture: ['architecture_id', 'organization_id', 'location_id'],
    os: ['operatingsystem_id', 'organization_id', 'location_id'],
    medium: ['medium_id', 'operatingsystem_id', 'architecture_id'],
    image: ['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id'],
  };
  let attrsToPost = defaultAttributes[componentType];

  if (attrsToPost === undefined) {
    return [];
  }
  if (pluginEditAttributes[componentType] !== undefined) {
    attrsToPost = attrsToPost.concat(pluginEditAttributes[componentType]);
  }
  return uniq(attrsToPost);
}

export function copyRegistrationCommand() {
  const commandText = document.getElementById('registration_command')
    .textContent;
  const tmpElement = document.createElement('textarea');

  tmpElement.textContent = commandText;
  document.body.appendChild(tmpElement);
  tmpElement.select();
  document.execCommand('copy');
  document.body.removeChild(tmpElement);
}

class PXECompatibilityCheck {
  constructor(regexp, compatibleLoadersFunc) {
    this.__regexp = regexp;
    this.__compatibleLoadersFunc = compatibleLoadersFunc;
  }

  isCompatible(osTitle, pxeLoader) {
    const os = this.__regexp.exec(osTitle);

    if (os == null) {
      return null;
    }

    const supportedLoaders = this.__compatibleLoadersFunc(os);
    if (supportedLoaders != null) {
      return supportedLoaders.indexOf(pxeLoader) > -1;
    }
    return null;
  }
}

/* eslint-disable no-unused-vars */
const PXE_BIOS = 'PXELinux BIOS';
const PXE_UEFI = 'PXELinux UEFI';
const GRUB_UEFI = 'Grub UEFI';
const GRUB2_UEFI = 'Grub2 UEFI';
const GRUB2_UEFI_SB = 'Grub2 UEFI SecureBoot';

export const pxeCompatibility = {};

// Ubuntu 10.x or older and Grub1
// Ubuntu 11.x or newer and Grub2
set(
  pxeCompatibility,
  'ubuntu',
  new PXECompatibilityCheck(/ubuntu[^\d]*(\d+)(?:[.]\d+)?/, os => {
    if (os[1] <= '10') {
      return [PXE_BIOS, GRUB_UEFI];
    } else if (os[1] > '10') {
      return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
    }
    return null;
  })
);

// RHEL 6.x and Grub1
// RHEL 7.x and Grub2
set(
  pxeCompatibility,
  'rhel',
  new PXECompatibilityCheck(
    /(?:red[ ]*hat|rhel|cent[ ]*os|scientific|oracle)[^\d]*(\d+)(?:[.]\d+)?/,
    os => {
      if (os[1] === '6') {
        return [PXE_BIOS, GRUB_UEFI];
      } else if (os[1] >= '7') {
        return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
      }
      return null;
    }
  )
);

// Debian 2-6 and Grub1
// Debian 7+ and Grub2
set(
  pxeCompatibility,
  'debian',
  new PXECompatibilityCheck(/debian[^\d]*(\d+)(?:[.]\d+)?/, os => {
    if (os[1] >= '2' && os[1] <= '6') {
      return [PXE_BIOS, GRUB_UEFI];
    } else if (os[1] > '6') {
      return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
    }
    return null;
  })
);

export function checkPXELoaderCompatibility(osTitle, pxeLoader) {
  if (pxeLoader === 'None' || pxeLoader === '') {
    return null;
  }
  let compatible = null;

  // eslint-disable-next-line no-param-reassign
  osTitle = osTitle.toLowerCase();
  Object.values(pxeCompatibility).forEach(check => {
    const compatibleCheck = check.isCompatible(osTitle, pxeLoader);

    if (compatibleCheck != null) {
      compatible = compatibleCheck;
    }
  });
  return compatible;
}
