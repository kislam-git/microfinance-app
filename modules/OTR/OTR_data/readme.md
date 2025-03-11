# Daily OTR data Preservation

## Process Flow
* Data Will be insert form the procedure Proc_loan_realization_day which is produce before day close OTR informaiton
* Data Will be update from the procedure Proc_loan_realization which is run produce after day close OTR informaiton
    
### Tables
* MF_OTR_INFO_COMP_DAY
   - Component wise data will be preserve on this table
* MF_OTR_INFO_CO_DAY
   - CO wise data will be preserve on this table
* MF_OTR_INFO_BRANCH_DAY
   - Branch wise data will be preserve on this table

### Synonyms

    CREATE OR REPLACE SYNONYM MF_OTR_INFO_BRANCH_DAY FOR MF_OTR_INFO_BRANCH_DAY@PO_;
    CREATE OR REPLACE SYNONYM MF_OTR_INFO_COMP_DAY FOR MF_OTR_INFO_COMP_DAY@PO_;
    CREATE OR REPLACE SYNONYM MF_OTR_INFO_CO_DAY FOR MF_OTR_INFO_CO_DAY@PO_;
