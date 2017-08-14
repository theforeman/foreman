import _ from 'lodash';

let pluginEditAttributes = {
  architecture: [],
  os: [],
  medium: [],
  image: []
};

export function registerPluginAttributes(componentType, attributes) {
  if (pluginEditAttributes[componentType] !== undefined) {
    pluginEditAttributes[componentType] = _.uniq(
      pluginEditAttributes[componentType].concat(attributes));
  }
}

export function getAttributesToPost(componentType) {
  const defaultAttributes = {
    'architecture': ['architecture_id', 'organization_id', 'location_id'],
    'os': ['operatingsystem_id', 'organization_id', 'location_id'],
    'medium': ['medium_id', 'operatingsystem_id', 'architecture_id'],
    'image': ['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id']
  };
  let attrsToPost = defaultAttributes[componentType];

  if (attrsToPost === undefined) {
    return [];
  }
  if (pluginEditAttributes[componentType] !== undefined) {
      attrsToPost = attrsToPost.concat(pluginEditAttributes[componentType]);
  }
  return _.uniq(attrsToPost);
}

class PXECompatibilityCheck {
  constructor(regexp, compatibleLoadersFunc) {
    this.__regexp = regexp;
    this.__compatibleLoadersFunc = compatibleLoadersFunc;
  }

  isCompatible(osTitle, pxeLoader) {
    let os, supportedLoaders;

    os = this.__regexp.exec(osTitle);
    if (os == null) {
      return null;
    }

    supportedLoaders = this.__compatibleLoadersFunc(os);
    if (supportedLoaders != null) {
      return (supportedLoaders.indexOf(pxeLoader) > -1);
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

export let pxeCompatibility = new Map();

// Ubuntu 10.x or older and Grub1
// Ubuntu 11.x or newer and Grub2
pxeCompatibility.set('ubuntu',
  new PXECompatibilityCheck(
    /ubuntu[^\d]*(\d+)(?:[.]\d+)?/,
    function (os) {
      if (os[1] <= '10') {
        return [PXE_BIOS, GRUB_UEFI];
      } else if (os[1] > '10') {
        return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
      }
      return null;
    }
  )
);

// RHEL 6.x and Grub1
// RHEL 7.x and Grub2
pxeCompatibility.set('rhel',
  new PXECompatibilityCheck(
    /(?:red[ ]*hat|rhel|cent[ ]*os|scientific|oracle)[^\d]*(\d+)(?:[.]\d+)?/,
    function (os) {
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
pxeCompatibility.set('debian',
  new PXECompatibilityCheck(
    /debian[^\d]*(\d+)(?:[.]\d+)?/,
    function (os) {
      if (os[1] >= '2' && os[1] <= '6') {
        return [PXE_BIOS, GRUB_UEFI];
      } else if (os[1] > '6') {
        return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
      }
      return null;
    }
  )
);

export function checkPXELoaderCompatibility(osTitle, pxeLoader) {
  if (pxeLoader === 'None' || pxeLoader === '') {
    return null;
  }

  osTitle = osTitle.toLowerCase();
  for (let check of pxeCompatibility.values()) {
    let compatible = check.isCompatible(osTitle, pxeLoader);

    if (compatible != null) {
      return compatible;
    }
  }
  return null;
}
