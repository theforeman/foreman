import { useContext } from 'react';
import ModalContext from './ForemanModalContext';

// Because enzyme doesn't support useContext yet
export const useModalContext = () => useContext(ModalContext);

// to get enzyme hacky test to work
export default ModalContext;
