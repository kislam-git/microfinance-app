
**Base Tables** 

  1.  MF_LOAN_REALIZATION_DAY

**Related Tables**
  1.  MF_LOAN_REALIZATION

**Procedure**
  
    DECLARE
    
    BEGIN
    
         PROC_LOAN_REALIZATION_DAY(
                
                P_COMPANY           =>  '0532',
                P_BRANCH            =>  :P786_BRANCH,
                P_FINANCE_CODE      =>  '01',
                P_PROJECT_CODE      =>  '01',
                P_COMPONENT_CODE    =>  '02',
                P_MNYR              =>  :P786_MNYR,
                P_TRANS_DATE        =>  :P786_OPEN_DATE,
                P_USER              =>  :APP_USER
                
                ) ;
    
    END;

**How To**
  1.  Before Day close branch Will run this process from application Page No 786
  2.  This procedure keeps only single daya data
    
      
  
