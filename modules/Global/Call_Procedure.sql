DECLARE

  V_COMPANY    VARCHAR2(4) := 'X';
  V_BRANCH     VARCHAR2(4) := 'X';
  V_FINANCE_CODE     VARCHAR2(2) := 'X';
  V_PROJECT_CODE     VARCHAR2(2) := 'X';
  V_COMPONENT_CODE   VARCHAR2(2) := 'X';
  V_MNYR             VARCHAR2(7) := 'X';
  V_PROCESS_DATE      DATE       := 'X'; 

BEGIN

        PROC_DAY_CLS_PRC_RUN 
            ( 
                P_COMPANY           =>      V_COMPANY,
                P_BRANCH            =>      V_BRANCH,
                P_FINANCE_CODE      =>      V_FINANCE_CODE,
                P_PROJECT_CODE      =>      V_PROJECT_CODE,
                P_COMPONENT_CODE    =>      V_COMPONENT_CODE,
                P_MNYR              =>      V_MNYR,
                P_PROCESS_DATE      =>      V_PROCESS_DATE
                
                );


END;
