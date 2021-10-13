import { createSlice } from '@reduxjs/toolkit';
import uuidV1 from 'uuid/v1';

const initialState = {};
const toastsListSlice = createSlice({
  name: 'toasts',
  initialState,
  reducers: {
    addToast: {
      reducer: (state, { payload: { key, toast } }) => {
        state[key] = toast;
      },
      prepare: toast => {
        const key = toast.key || uuidV1();
        return { payload: { key, toast } };
      },
    },
    deleteToast: (state, { payload }) => {
      delete state[payload];
    },
    clearToasts: () => initialState,
  },
});

const { name, reducer, actions } = toastsListSlice;

export const { addToast, deleteToast, clearToasts } = actions;

export const reducers = { [name]: reducer };

export const selectToastsList = state => state[name];
