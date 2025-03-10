# When Day Day close process Run

      ------- RUN THIS PROCEDURE ON DAY CLOSE FOR SUMMARY DATA PROCESS
    create or replace PROCEDURE       PROC_DAY_CLS_PRC_RUN ( 
                      
          P_COMPANY           IN  VARCHAR2,
          P_BRANCH            IN  VARCHAR2,
          P_FINANCE_CODE      IN  CHAR,
          P_PROJECT_CODE      IN  CHAR,
          P_COMPONENT_CODE    IN  CHAR,
          P_MNYR              IN  VARCHAR2,
          P_PROCESS_DATE      IN DATE
      ) IS

      BEGIN
      
          DECLARE
                  V_WKYR          VARCHAR2(7) := GET_WEEK_STARTYR(P_PROCESS_DATE);
                  V_PRV_MNYR      VARCHAR2(7) := GET_PERIOD_STARTYR(ADD_MONTHS(P_PROCESS_DATE,-1));
                  V_USER          VARCHAR2(30)   :=   USER;
      
          BEGIN
      
                  DECLARE -------------------------------- RUN MF SAVINGS MNYR 
      
      
                  BEGIN
                          PROC_SAVE_MNYR 
                              ( 
                                      P_COMPANY           =>      P_COMPANY,
                                      P_BRANCH            =>      P_BRANCH,
                                      P_FINANCE_CODE      =>      P_FINANCE_CODE,
                                      P_PROJECT_CODE      =>      P_PROJECT_CODE,
                                      P_COMPONENT_CODE    =>      P_COMPONENT_CODE,
                                      P_MNYR              =>      P_MNYR,
                                      P_PRV_MNYR          =>      V_PRV_MNYR,
                                      P_USER              =>      V_USER
      
                              );
      
      
                  END;
                  
                  
                  DECLARE -------------------------------- RUN MF LOAN REALIZATION
      
      
                  BEGIN
                         
                               PROC_LOAN_REALIZATION (
      
                                              P_COMPANY           =>      P_COMPANY,
                                              P_BRANCH            =>      P_BRANCH,
                                              P_FINANCE_CODE      =>      P_FINANCE_CODE,
                                              P_PROJECT_CODE      =>      P_PROJECT_CODE,
                                              P_COMPONENT_CODE    =>      P_COMPONENT_CODE,
                                              P_CLOSE_DATE        =>      P_PROCESS_DATE,
                                              P_MNYR              =>      P_MNYR,
                                              P_PRV_MNYR          =>      V_PRV_MNYR,
                                              P_USER              =>      V_USER
                                      );
      
                  END;
                  
                  
                  DECLARE -------------------------------- RUN MF LOAN REALIZATION DAY
      
      
                  BEGIN
                         
                               PROC_LOAN_REALIZATION_DAY (
      
                                              P_COMPANY           =>      P_COMPANY,
                                              P_BRANCH            =>      P_BRANCH,
                                              P_FINANCE_CODE      =>      P_FINANCE_CODE,
                                              P_PROJECT_CODE      =>      P_PROJECT_CODE,
                                              P_COMPONENT_CODE    =>      P_COMPONENT_CODE,
                                              P_MNYR              =>      P_MNYR,
                                              P_TRANS_DATE        =>      P_PROCESS_DATE,
                                              P_USER              =>      V_USER
                                      );
                  END;

                  DECLARE
                          
                  BEGIN
                          
                              PROC_DAY_SUMMARY(
                                      P_COMPANY,P_BRANCH, P_FINANCE_CODE, P_PROJECT_CODE, P_COMPONENT_CODE,
                                      P_PROCESS_DATE,P_MNYR,V_WKYR,SUBSTR(P_MNYR,4,4)||'_'||TO_CHAR(SUBSTR(P_MNYR,6,2)+1));
                          
                  END;
                  
                  DECLARE -------------------------------- RUN MF DAY SUMMARY
      
                          V_DATE      DATE        :=  P_PROCESS_DATE;
                          --V_MNYR      VARCHAR2(7) :=  GET_PERIOD_STARTYR(V_DATE);
                          V_WKYR      VARCHAR2(7) :=  GET_WEEK_STARTYR(V_DATE);
                  BEGIN
                         
                                IF IS_HOLIDAY( P_COMPANY,  P_BRANCH, V_DATE ) = 'N' THEN
                      
                                      --DBMS_OUTPUT.PUT_LINE(V_DATE);
                  
                                      PROC_MF_DAY_SUMMARY
                                          (
                                              P_COMPANY           =>      P_COMPANY,
                                              P_BRANCH            =>      P_BRANCH,
                                              P_FINANCE_CODE      =>      P_FINANCE_CODE,
                                              P_PROJECT_CODE      =>      P_PROJECT_CODE,
                                              P_COMPONENT_CODE    =>      P_COMPONENT_CODE,
                                              P_TRANS_DATE        =>      V_DATE,
                                              P_MNYR              =>      P_MNYR,
                                              P_WKYR              =>      V_WKYR
                                          );
              
                                 -- ELSE 
                                         -- DBMS_OUTPUT.PUT_LINE('It is a Holiday '|| V_DATE );
                                  
                                  END IF;
                  END;
          END;
        END;
