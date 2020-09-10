import { useContext, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectIsModalOpen } from './ForemanModalSelectors';
import { setModalOpen, setModalClosed } from './ForemanModalActions';
import ModalContext from './ForemanModalContext';

// Because enzyme doesn't support useContext yet
export const useModalContext = () => useContext(ModalContext);

// Use in any ForemanModal.  Handles Redux actions for creating, opening, and closing the modal.
// Make sure the id passed in matches the id prop of your <ForemanModal />.
// Returns a variable that tells you the state and a function to toggle it.
export const useForemanModal = ({ id, isOpen = false }) => {
  if (!id) throw new Error('useForemanModal: ID is required');
  const initialModalState = isOpen;
  const modalOpen = useSelector(state => selectIsModalOpen(state, id)) || false;
  const dispatch = useDispatch();
  const boundSetModalClosed = () => dispatch(setModalClosed({ id }));
  const boundSetModalOpen = () => dispatch(setModalOpen({ id }));

  useEffect(() => {
    if (initialModalState === true) boundSetModalOpen();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return {
    modalOpen,
    setModalOpen: boundSetModalOpen,
    setModalClosed: boundSetModalClosed,
  };
};

// to get enzyme hacky test to work
export default ModalContext;
