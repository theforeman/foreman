import { useEffect, useState } from 'react';

// Global states for storing modal open statuses and their listeners
const modalState = {};

// Object of React state setters ex:
// {
//     "bulk-assign-cves-modal": [setIsOpen],
//     "bulk-packages-wizard": [setIsOpen],
// }
const modalStateOpeners = {};

/**
 * Register a modal to a listener:
 * This helper should used only in situations where useState hook is not
 * available, e.g. when the modal is mounted by global fill
 * @param {String} id - an identifier for the modal
 * @param {Boolean} isOpen - whether a modal is open
 */
export const openBulkModal = (id, isOpen) => {
  // Avoid unnecessary updates
  if (modalState[id] === isOpen) return;

  if (isOpen) modalState[id] = true;
  else delete modalState[id];

  (modalStateOpeners[id] || []).forEach(listener => listener(isOpen));
};

/**
 * Access modals and their helper functions
 * @param {String} id - identifier of the modal
 */
export const useBulkModalOpen = id => {
  const [isOpen, setIsOpen] = useState(() => Boolean(modalState[id]));

  useEffect(() => {
    if (!modalStateOpeners[id]) modalStateOpeners[id] = [];

    // Prevent duplicate subscriptions
    if (!modalStateOpeners[id].includes(setIsOpen)) {
      modalStateOpeners[id].push(setIsOpen);
    }

    return () => {
      modalStateOpeners[id] = modalStateOpeners[id].filter(
        l => l !== setIsOpen
      );
      // Cleanup empty listener arrays
      if (modalStateOpeners[id].length === 0) {
        delete modalStateOpeners[id];
      }
    };
  }, [id]);

  // Return with helper functions
  return {
    isOpen,
    open: () => openBulkModal(id, true),
    close: () => openBulkModal(id, false),
    toggle: () => openBulkModal(id, !isOpen),
  };
};
