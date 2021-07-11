import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  modalToDisplay: {},
};

const factChartSlice = createSlice({
  name: 'factChart',
  initialState,
  reducers: {
    openModal(state, { payload }) {
      state.title = payload.title;
      state.modalToDisplay = { [payload.id]: true };
    },
    closeModal(state) {
      state.modalToDisplay = {};
    },
  },
});

export const { openModal, closeModal } = factChartSlice.actions;
export default factChartSlice.reducer;
