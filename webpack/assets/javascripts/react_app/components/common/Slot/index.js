import { connect } from 'react-redux';
import { selectFillsComponents } from './SlotSelectors';
import Slot from './Slot';

// map state to props
const mapStateToProps = (state, ownProps) => ({
  fills: selectFillsComponents(state, {
    id: ownProps.id,
    multiple: ownProps.multi,
  }),
});

// export connected component
export default connect(mapStateToProps)(Slot);
