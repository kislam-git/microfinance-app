# Procedure PROC_LOAN_REALIZATION

          create or replace PROCEDURE PROC_LOAN_REALIZATION
          (
             P_COMPANY     IN VARCHAR2,
             P_BRANCH     IN VARCHAR2,
             P_FINANCE_CODE   IN       CHAR,
             P_PROJECT_CODE   IN       CHAR,
             P_COMPONENT_CODE IN       CHAR,
             P_CLOSE_DATE     IN DATE,
             P_MNYR       IN VARCHAR2,
             P_PRV_MNYR   IN VARCHAR2,
             P_USER       IN VARCHAR2
          )
          IS
          
          BEGIN
              DECLARE
              V_COMPANY      VARCHAR2(4) := P_COMPANY;
              V_BRANCH       VARCHAR2(4) := P_BRANCH;
              V_MNYR         VARCHAR2(7) := P_MNYR;
             -- V_OPN_WKYR     VARCHAR2(7) := P_OPN_WKYR;
              V_PRV_MNYR     VARCHAR2(7) := P_PRV_MNYR;
          
              V_DAY_OPN       DATE;
              V_WKYR VARCHAR2(7):= GET_WEEK_STARTYR(P_CLOSE_DATE);
              
               
            
              
              CURSOR C1 IS
          
                  SELECT  COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO
          ------------------------------------------------------ DUE RECEIVED --- REGULAR RECEIVED ---- ADVANCE RECEIVED -----------
          
              -------------------------------------------------- WITH SC ----------------------------------------------------
              , OPENING_LOAN_WSC , OPENING_DUE_WSC , OPENING_ADVANCE_WSC
              , RECEIVABLE_WSC , TOTAL_RECEIVED_WSC
                  , NVL(CASE
                          WHEN OPENING_DUE_WSC >= RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC <= OPENING_DUE_WSC THEN TOTAL_RECEIVED_WSC
                          WHEN OPENING_DUE_WSC >= RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC > OPENING_DUE_WSC THEN OPENING_DUE_WSC
                          WHEN OPENING_DUE_WSC < RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC > OPENING_DUE_WSC THEN OPENING_DUE_WSC
                          WHEN OPENING_DUE_WSC < RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC <= OPENING_DUE_WSC THEN TOTAL_RECEIVED_WSC
                          END,0) DUE_RCVD_WSC
                  , NVL(CASE
          
                          WHEN OPENING_DUE_WSC >= RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC + RECEIVABLE_WSC  THEN RECEIVABLE_WSC
                          WHEN OPENING_DUE_WSC > 0 AND OPENING_DUE_WSC < RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC + RECEIVABLE_WSC  THEN  RECEIVABLE_WSC
                          WHEN OPENING_DUE_WSC > 0 AND OPENING_DUE_WSC < RECEIVABLE_WSC
                                  AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC  THEN TOTAL_RECEIVED_WSC - OPENING_DUE_WSC
                          -- IF DUE GRATER THAN RECEIVABLE AND RECEIVED GRATER THAN DUE AND LESS THAN DUE + RCVLBE THEN
                          WHEN OPENING_DUE_WSC >= RECEIVABLE_WSC
                                  AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC  AND  TOTAL_RECEIVED_WSC < OPENING_DUE_WSC + RECEIVABLE_WSC
                                  THEN TOTAL_RECEIVED_WSC - OPENING_DUE_WSC  
          
                          WHEN OPENING_DUE_WSC = 0 AND TOTAL_RECEIVED_WSC <= RECEIVABLE_WSC THEN TOTAL_RECEIVED_WSC
                          WHEN OPENING_DUE_WSC = 0 AND TOTAL_RECEIVED_WSC >= RECEIVABLE_WSC THEN RECEIVABLE_WSC
                          END,0) REG_RCVD_WSC
          
                  , NVL(CASE
                          WHEN TOTAL_RECEIVED_WSC > OPENING_DUE_WSC + RECEIVABLE_WSC THEN TOTAL_RECEIVED_WSC  - (OPENING_DUE_WSC + RECEIVABLE_WSC)
                          WHEN OPENING_DUE_WSC = 0 AND TOTAL_RECEIVED_WSC > RECEIVABLE_WSC THEN TOTAL_RECEIVED_WSC - RECEIVABLE_WSC
                          END,0) ADV_RCVD_WSC
                   ------------------------------------------ ADVANCE ADJUST
                   , NVL(CASE
                          WHEN OPENING_ADVANCE_WSC > 0 AND  TOTAL_RECEIVED_WSC < RECEIVABLE_WSC AND OPENING_ADVANCE_WSC <= RECEIVABLE_WSC  - TOTAL_RECEIVED_WSC
                                  THEN OPENING_ADVANCE_WSC
                           WHEN OPENING_ADVANCE_WSC > 0 AND TOTAL_RECEIVED_WSC < RECEIVABLE_WSC AND OPENING_ADVANCE_WSC > RECEIVABLE_WSC  - TOTAL_RECEIVED_WSC
                                  THEN RECEIVABLE_WSC - TOTAL_RECEIVED_WSC
                          END,0) ADVANCE_ADJUST_WSC
          
              ---------------------------------------------------- PRN ------------------------------------------------------------
              , OPENING_LOAN_PRN , OPENING_DUE_PRN  , OPENING_ADVANCE_PRN
              , RECEIVABLE_PRN , TOTAL_RECEIVED_PRN
                                  , NVL(CASE
                                          WHEN OPENING_DUE_PRN >= RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN <= OPENING_DUE_PRN THEN TOTAL_RECEIVED_PRN
                                          WHEN OPENING_DUE_PRN >= RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN > OPENING_DUE_PRN THEN OPENING_DUE_PRN
                                          WHEN OPENING_DUE_PRN < RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN > OPENING_DUE_PRN THEN OPENING_DUE_PRN
                                          WHEN OPENING_DUE_PRN < RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN <= OPENING_DUE_PRN THEN TOTAL_RECEIVED_PRN
                                          END,0) DUE_RCVD_PRN
                                  ------------------------------------- REGULAR RCVD PRN
                                  , NVL(CASE
                                          --WHEN OPENING_DUE_PRN >= RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN < OPENING_DUE_PRN + RECEIVABLE_PRN  THEN TOTAL_RECEIVED_PRN  - OPENING_DUE_PRN
                                          WHEN OPENING_DUE_PRN >= RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN >= OPENING_DUE_PRN + RECEIVABLE_PRN  THEN RECEIVABLE_PRN
                                          WHEN OPENING_DUE_PRN > 0 AND OPENING_DUE_PRN < RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN >= OPENING_DUE_PRN + RECEIVABLE_PRN  THEN  RECEIVABLE_PRN
                                          WHEN OPENING_DUE_PRN > 0 AND OPENING_DUE_PRN < RECEIVABLE_PRN
                                              AND TOTAL_RECEIVED_PRN >= OPENING_DUE_PRN  THEN TOTAL_RECEIVED_PRN - OPENING_DUE_PRN
                                          -- IF DUE GRATER THAN RECEIVABLE AND RECEIVED GRATER THAN DUE AND LESS THAN DUE + RCVLBE THEN
                                          WHEN OPENING_DUE_WSC >= RECEIVABLE_WSC
                                              AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC  AND  TOTAL_RECEIVED_WSC < OPENING_DUE_WSC + RECEIVABLE_WSC
                                              THEN TOTAL_RECEIVED_WSC - OPENING_DUE_WSC  
          
                                          WHEN OPENING_DUE_PRN = 0 AND TOTAL_RECEIVED_PRN <= RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN
                                          WHEN OPENING_DUE_PRN = 0 AND TOTAL_RECEIVED_PRN >= RECEIVABLE_PRN THEN RECEIVABLE_PRN
                                          END,0) REG_RCVD_PRN
          
                                  ------------ ADVANCE RECEIVED
                                  , NVL(CASE
                                          WHEN TOTAL_RECEIVED_PRN > OPENING_DUE_PRN + RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN  - (OPENING_DUE_PRN + RECEIVABLE_PRN)
                                          --WHEN OPENING_DUE_PRN = 0 AND TOTAL_RECEIVED_PRN <= RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN
                                          WHEN OPENING_DUE_PRN = 0 AND TOTAL_RECEIVED_PRN > RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN - RECEIVABLE_PRN
                                          END,0) ADV_RCVD_PRN
                              ------------------------------------------ ADVANCE ADJUST PRN
                               , NVL(CASE
                                      WHEN OPENING_ADVANCE_PRN > 0 AND  TOTAL_RECEIVED_PRN < RECEIVABLE_PRN AND OPENING_ADVANCE_PRN <= RECEIVABLE_PRN  - TOTAL_RECEIVED_PRN
                                              THEN OPENING_ADVANCE_PRN
                                       WHEN OPENING_ADVANCE_PRN > 0 AND TOTAL_RECEIVED_PRN < RECEIVABLE_PRN AND OPENING_ADVANCE_PRN > RECEIVABLE_PRN  - TOTAL_RECEIVED_PRN
                                              THEN RECEIVABLE_PRN - TOTAL_RECEIVED_PRN
                                      END,0) ADVANCE_ADJ_PRN
          ------------------END OF DUE RECEIVED ----- REGULAR RECEIVED ----------- ADVANCE RECEIVED ------------------------
          
          -------------------------- START ---- REGULAR--DUE--ADVANCE METHOD -------------   08.12.2020
          
                          ------------------- REGULAR RECEIVED -------------------
          
                 ,  NVL(CASE  WHEN RECEIVABLE_WSC > 0 AND  TOTAL_RECEIVED_WSC <= RECEIVABLE_WSC THEN  TOTAL_RECEIVED_WSC  
                              WHEN RECEIVABLE_WSC > 0 AND  TOTAL_RECEIVED_WSC > RECEIVABLE_WSC THEN  RECEIVABLE_WSC
                          END,0)REG_RCVD_WSC_NEW
          
                  , NVL(CASE  WHEN OPENING_DUE_WSC > 0 AND TOTAL_RECEIVED_WSC >=  RECEIVABLE_WSC + OPENING_DUE_WSC THEN OPENING_DUE_WSC
                          WHEN OPENING_DUE_WSC > 0 AND TOTAL_RECEIVED_WSC > RECEIVABLE_WSC AND TOTAL_RECEIVED_WSC <=  RECEIVABLE_WSC + OPENING_DUE_WSC
                                  THEN TOTAL_RECEIVED_WSC - RECEIVABLE_WSC
                         -- WHEN OPENING_DUE_WSC > 0 AND RECEIVABLE_WSC = 0  AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC THEN TOTAL_RECEIVED_WSC
          
                          END, 0)DEU_RCVD_WSC_NEW
          
                    , NVL(CASE
                          WHEN TOTAL_RECEIVED_WSC > OPENING_DUE_WSC + RECEIVABLE_WSC THEN TOTAL_RECEIVED_WSC  - (OPENING_DUE_WSC + RECEIVABLE_WSC)
                          WHEN OPENING_DUE_WSC = 0 AND TOTAL_RECEIVED_WSC > RECEIVABLE_WSC THEN TOTAL_RECEIVED_WSC - RECEIVABLE_WSC
                          END,0) ADV_RCVD_WSC_NEW   
          
            ------------------- REGULAR RECEIVED PRINCIPAL-------------------
          
                 ,  NVL(CASE  WHEN RECEIVABLE_PRN > 0 AND  TOTAL_RECEIVED_PRN <= RECEIVABLE_PRN THEN  TOTAL_RECEIVED_PRN  
                              WHEN RECEIVABLE_PRN > 0 AND  TOTAL_RECEIVED_PRN > RECEIVABLE_PRN THEN  RECEIVABLE_PRN
                          END,0)REG_RCVD_PRN_NEW
          
                  , NVL(CASE  WHEN OPENING_DUE_PRN > 0 AND TOTAL_RECEIVED_PRN >=  RECEIVABLE_PRN + OPENING_DUE_PRN THEN OPENING_DUE_PRN
                          WHEN OPENING_DUE_PRN > 0 AND TOTAL_RECEIVED_PRN > RECEIVABLE_PRN AND TOTAL_RECEIVED_PRN <=  RECEIVABLE_PRN + OPENING_DUE_PRN
                                  THEN TOTAL_RECEIVED_PRN - RECEIVABLE_PRN
                         -- WHEN OPENING_DUE_WSC > 0 AND RECEIVABLE_WSC = 0  AND TOTAL_RECEIVED_WSC >= OPENING_DUE_WSC THEN TOTAL_RECEIVED_WSC
          
                          END, 0)DEU_RCVD_PRN_NEW
          
                    , NVL(CASE
                          WHEN TOTAL_RECEIVED_PRN > OPENING_DUE_PRN + RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN  - (OPENING_DUE_PRN + RECEIVABLE_PRN)
                          WHEN OPENING_DUE_PRN = 0 AND TOTAL_RECEIVED_PRN > RECEIVABLE_PRN THEN TOTAL_RECEIVED_PRN - RECEIVABLE_PRN
                          END,0) ADV_RCVD_PRN_NEW                      
          
          
              FROM
                  (
                  SELECT COMPANY_BRANCH_CODE,  SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO --, MNYR
          
                          , SUM(OPN_LOAN_WSC) OPENING_LOAN_WSC , SUM(OPN_DUE_WSC) OPENING_DUE_WSC
                          , SUM(OPN_ADVANCE_WSC) OPENING_ADVANCE_WSC
                          , SUM(RCVBLE_WSC) RECEIVABLE_WSC , SUM(TOTAL_RCVD_WSC) TOTAL_RECEIVED_WSC
          
                          , SUM(OPN_LOAN_PRN) OPENING_LOAN_PRN , SUM(OPN_DUE_PRN) OPENING_DUE_PRN
                          , SUM(OPN_ADVANCE_PRN) OPENING_ADVANCE_PRN
                          , SUM(RCVBLE_PRN) RECEIVABLE_PRN , SUM(TOTAL_RCVD_PRN) TOTAL_RECEIVED_PRN
                  FROM
                      (
                      SELECT COMPANY_BRANCH_CODE,  SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          , OPN_LOAN_WSC , OPN_DUE_WSC , OPN_ADVANCE_WSC , 0 RCVBLE_WSC , 0 TOTAL_RCVD_WSC
                          , OPN_LOAN_PRN , OPN_DUE_PRN  , OPN_ADVANCE_PRN , 0 RCVBLE_PRN , 0 TOTAL_RCVD_PRN
                      FROM  
                          (
                          SELECT /*+ INDEX(PK_LOAN_BAL_WKYR)*/ COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR --, WKYR, INSTALL_NO
                                , NVL(LOAN_OUTSTANDING,0) OPN_LOAN_WSC , NVL(LOAN_OVERDUE,0) OPN_DUE_WSC
                                , NVL(LOAN_ADVANCE,0) OPN_ADVANCE_WSC
          
                                , NVL(LOAN_OUT_PRN,0) OPN_LOAN_PRN , NVL(LOAN_OD_PRN,0) OPN_DUE_PRN
                                , NVL(LOAN_ADV_PRN,0) OPN_ADVANCE_PRN
          
                          FROM LOAN_BAL_WKYR
                          WHERE COMPANY_CODE = P_COMPANY
                          AND COMPANY_BRANCH_CODE = V_BRANCH
                          AND FINANCE_CODE = P_FINANCE_CODE
                          AND PROJECT_CODE = P_PROJECT_CODE
                          AND COMPONENT_CODE = P_COMPONENT_CODE
                          AND MNYR = V_PRV_MNYR
                          AND WKYR = (SELECT DISTINCT WKYR   FROM PROCESS_CONTROL WHERE PROCESS_DATE=  (SELECT /*+ INDEX(PK_PROCESS_CONTROL) */  MAX(PROCESS_DATE)
                                         
                                          FROM PROCESS_CONTROL
                                          WHERE
                                          COMPANY_CODE = P_COMPANY AND
                                          (COMPANY_BRANCH_CODE = V_BRANCH  OR V_BRANCH IS NULL)
                                          AND
                                          FINANCE_CODE = P_FINANCE_CODE AND
                                          PROJECT_CODE = P_PROJECT_CODE AND
                                          COMPONENT_CODE = P_COMPONENT_CODE AND
                                          MNYR =P_PRV_MNYR AND 
                                          DAY_CLOSE_FLAG = 'Y'))
                         
                          )
                      UNION ALL
                      
                       SELECT COMPANY_BRANCH_CODE,  SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          , OPN_LOAN_WSC , OPN_DUE_WSC , OPN_ADVANCE_WSC , 0 RCVBLE_WSC , 0 TOTAL_RCVD_WSC
                          , OPN_LOAN_PRN , OPN_DUE_PRN  , OPN_ADVANCE_PRN , 0 RCVBLE_PRN , 0 TOTAL_RCVD_PRN
                      FROM  
                          (
                          SELECT  /*+ INDEX(PK_LOAN_BAL_WKYR)*/ L.COMPANY_BRANCH_CODE , L.SAMITY_CODE , L.MEMBER_ID , L.LOAN_CODE , L.DAFA_NO , L.MNYR --, WKYR, INSTALL_NO
                                , NVL(LOAN_OUTSTANDING,0) OPN_LOAN_WSC , NVL(LOAN_OVERDUE,0) OPN_DUE_WSC
                                , NVL(LOAN_ADVANCE,0) OPN_ADVANCE_WSC
          
                                , NVL(LOAN_OUT_PRN,0) OPN_LOAN_PRN , NVL(LOAN_OD_PRN,0) OPN_DUE_PRN
                                , NVL(LOAN_ADV_PRN,0) OPN_ADVANCE_PRN
          
                          FROM LOAN_BAL_WKYR L, LOAN_BAL B
                          WHERE L.COMPANY_CODE = B.COMPANY_CODE
                          AND L.COMPANY_BRANCH_CODE = B.COMPANY_BRANCH_CODE
                          AND L.SAMITY_CODE = B.SAMITY_CODE
                          AND L.MEMBER_ID = B.MEMBER_ID
                          AND L.LOAN_CODE = B.LOAN_CODE
                          AND L.DAFA_NO = B.DAFA_NO
                          AND B.TRANSFER_IN_FLAG ='Y'
                          AND L.MNYR = B.BAL_MNYR
                          AND L.WKYR=B.BAL_WKYR
                          AND L.COMPANY_CODE = P_COMPANY
                          AND L.COMPANY_BRANCH_CODE = V_BRANCH
                          AND L.FINANCE_CODE = P_FINANCE_CODE
                          AND L.PROJECT_CODE = P_PROJECT_CODE
                          AND L.COMPONENT_CODE = P_COMPONENT_CODE
                          AND L.MNYR =V_MNYR
                          )
                           UNION ALL
                          
          
                    
          
                      SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          , 0 OPN_LOAN_WSC , 0 OPN_DUE_WSC , 0 OPN_ADVANCE_WSC ,  RCVBLE_WSC ,  TOTAL_RCVD_WSC
                          , 0 PN_LOAN , 0 OPN_DUE  , 0 OPN_ADVANCE,  RCVBLE_PRN , TOTAL_RCVD_PRN
                      FROM
                          (
                          SELECT  /*+ INDEX(PK_LOAN_BAL_WKYR)*/  COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR  
                                     , NVL(SUM(LOAN_RCVBLE),0) RCVBLE_WSC , NVL(SUM(TTL_INSTALL_AMT_RCVD),0) TOTAL_RCVD_WSC
                                      , NVL(SUM(LOAN_RCVBLE_PRN),0) RCVBLE_PRN
                                      , NVL(SUM(TTL_INST_PRN_RCVD),0) TOTAL_RCVD_PRN
                          FROM LOAN_BAL_WKYR
                          WHERE COMPANY_CODE = P_COMPANY
                          AND COMPANY_BRANCH_CODE = V_BRANCH
                          AND FINANCE_CODE = P_FINANCE_CODE
                          AND PROJECT_CODE = P_PROJECT_CODE
                          AND COMPONENT_CODE = P_COMPONENT_CODE
                          AND MNYR = V_MNYR
                          AND WKYR <> V_WKYR
                          --AND SAMITY_CODE = '00011028'
                          --AND MEMBER_ID = '0001114147'
                          GROUP BY COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          )
          union all
                           SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          , 0 OPN_LOAN_WSC , 0 OPN_DUE_WSC , 0 OPN_ADVANCE_WSC ,  RCVBLE_WSC ,  TOTAL_RCVD_WSC
                          , 0 PN_LOAN , 0 OPN_DUE  , 0 OPN_ADVANCE,  RCVBLE_PRN , TOTAL_RCVD_PRN
                      FROM
                          (
                          SELECT /*+ INDEX(PK_LOAN_BAL_WKYR)*/ COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR  
                                   , NVL(SUM(LOAN_RCVBLE),0) RCVBLE_WSC , 0 TOTAL_RCVD_WSC
                                      , NVL(SUM(LOAN_RCVBLE_PRN),0) RCVBLE_PRN
                                      , 0 TOTAL_RCVD_PRN
                          FROM LOAN_BAL_WKYR
                          WHERE COMPANY_CODE = P_COMPANY
                          AND COMPANY_BRANCH_CODE = V_BRANCH
                          AND FINANCE_CODE = P_FINANCE_CODE
                          AND PROJECT_CODE = P_PROJECT_CODE
                          AND COMPONENT_CODE = P_COMPONENT_CODE
                          AND MNYR = V_MNYR
                          AND WKYR = V_WKYR
                         AND SAMITY_CODE IN
              (
                  SELECT /*+ INDEX(PK_COLLECTION_SHEET)*/ DISTINCT SAMITY_CODE 
                  FROM COLLECTION_SHEET
                  WHERE COMPANY_CODE = P_COMPANY
                          AND COMPANY_BRANCH_CODE = V_BRANCH
                          AND FINANCE_CODE = P_FINANCE_CODE
                          AND PROJECT_CODE = P_PROJECT_CODE
                          AND COMPONENT_CODE = P_COMPONENT_CODE
                          AND MNYR = V_MNYR
                  AND WKYR =  V_WKYR
             
              )
                      
                          GROUP BY COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          )
                          
          union all
                           SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR
                          , 0 OPN_LOAN_WSC , 0 OPN_DUE_WSC , 0 OPN_ADVANCE_WSC ,  RCVBLE_WSC ,  TOTAL_RCVD_WSC
                          , 0 PN_LOAN , 0 OPN_DUE  , 0 OPN_ADVANCE,  RCVBLE_PRN , TOTAL_RCVD_PRN
                      FROM
                          (
                          SELECT  /*+ INDEX(PK_LOAN_BAL_WKYR)*/ COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR  
                                   , 0 RCVBLE_WSC , NVL(SUM(TTL_INSTALL_AMT_RCVD),0) TOTAL_RCVD_WSC
                                      , 0 RCVBLE_PRN
                                      , NVL(SUM(TTL_INST_PRN_RCVD),0) TOTAL_RCVD_PRN
                          FROM LOAN_BAL_WKYR
                          WHERE  COMPANY_CODE = P_COMPANY
                          AND COMPANY_BRANCH_CODE = V_BRANCH
                          AND FINANCE_CODE = P_FINANCE_CODE
                          AND PROJECT_CODE = P_PROJECT_CODE
                          AND COMPONENT_CODE = P_COMPONENT_CODE
                          AND MNYR = V_MNYR
                          AND WKYR =  V_WKYR
                          
                          GROUP BY COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , MNYR)
                      )
                  GROUP BY COMPANY_BRANCH_CODE,  SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO --, MNYR
               )
               ;
          
          BEGIN  
                  SELECT /*+ INDEX(PK_PROCESS_CONTROL) */ MAX(PROCESS_DATE)  A 
                  INTO V_DAY_OPN
                  FROM PROCESS_CONTROL
                  WHERE COMPANY_CODE = P_COMPANY
                  AND COMPANY_BRANCH_CODE = V_BRANCH
                  AND FINANCE_CODE = P_FINANCE_CODE
                  AND PROJECT_CODE = P_PROJECT_CODE
                  AND COMPONENT_CODE = P_COMPONENT_CODE
                  AND DAY_OPEN_FLAG = 'Y'
                  AND DAY_CLOSE_FLAG IS NULL
                  ;
          
                  DELETE  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION
                  WHERE 
                  COMPANY_CODE = V_COMPANY  
                  AND COMPANY_BRANCH_CODE = V_BRANCH
                  AND FINANCE_CODE = P_FINANCE_CODE
                  AND PROJECT_CODE = P_PROJECT_CODE
                  AND COMPONENT_CODE = P_COMPONENT_CODE
                  AND MNYR = V_MNYR
                  ;
                  COMMIT;
          
                  FOR R IN C1
                  LOOP
          
                      INSERT INTO  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION
                      (
                          COMPANY_CODE , COMPANY_BRANCH_CODE ,  MNYR , SAMITY_CODE, MEMBER_ID , LOAN_CODE , DAFA_NO, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE
                          , OPENING_LOAN_WSC, OPENING_DUE_WSC , OPENING_ADVANCE_WSC, RECEIVABLE_WSC, TOTAL_RECEIVED_WSC
                          , DUE_RCVD_WSC , REG_RCVD_WSC, ADV_RCVD_WSC, OPENING_LOAN_PRN, OPENING_DUE_PRN, OPENING_ADVANCE_PRN
                          , RECEIVABLE_PRN, TOTAL_RECEIVED_PRN, DUE_RCVD_PRN,REG_RCVD_PRN, ADV_RCVD_PRN, UPDATE_BY,  UPDATE_TIME
                          , ADVANCE_ADJUST_WSC, ADVANCE_ADJ_PRN, MONTH_TTL_RCVBLE_WSC, MONTH_TTL_RCVBLE_PRN
                          , MONTH_TTL_REG_RCVD_WSC, MONTH_TTL_REG_RCVD_PRN, LOAN_TYPE, RECOVERY_FLAG, RECOVERY_DATE
                          , INS_DATE, LAST_CLS_DATE
          
                      )
                      VALUES
                      (
                          P_COMPANY , R.COMPANY_BRANCH_CODE , V_MNYR,  R.SAMITY_CODE , R.MEMBER_ID , R.LOAN_CODE , R.DAFA_NO, P_FINANCE_CODE, P_PROJECT_CODE, P_COMPONENT_CODE
                          , R.OPENING_LOAN_WSC , R.OPENING_DUE_WSC , R.OPENING_ADVANCE_WSC
                          , R.RECEIVABLE_WSC , R.TOTAL_RECEIVED_WSC
                          , R.DEU_RCVD_WSC_NEW , R.REG_RCVD_WSC_NEW , R.ADV_RCVD_WSC_NEW
                          , R.OPENING_LOAN_PRN , R.OPENING_DUE_PRN , R.OPENING_ADVANCE_PRN
                          , R.RECEIVABLE_PRN , R.TOTAL_RECEIVED_PRN
                          , R.DEU_RCVD_PRN_NEW , R.REG_RCVD_PRN_NEW , R.ADV_RCVD_PRN_NEW
                          ,  P_USER ,  CURRENT_TIMESTAMP
                          , R.ADVANCE_ADJUST_WSC , R.ADVANCE_ADJ_PRN
                          , 0 , 0 ,  0 , 0
                          , NULL , NULL, NULL
                          , SYSDATE , P_CLOSE_DATE
                      );
          
                      COMMIT;
          
                  END LOOP;
          
          
                  DECLARE ----------------------------------- MONTH TOTAL RECEIVABLE
                               CURSOR MTR1 IS
                                  SELECT    /*+ INDEX(PK_LOAN_REPAY_SCHEDULE)*/ 
                                  COMPANY_BRANCH_CODE , SAMITY_CODE ,  MEMBER_ID , LOAN_CODE , DAFA_NO
                                      , NVL(ROUND(SUM(INSTALL_AMT)),0) TTL_INST_AMT , NVL(ROUND(SUM(PRN_AMT)),0) TTL_INST_AMT_PRN
                                  FROM LOAN_REPAY_SCHEDULE --RICAPX.MF_LRPS_ARCHIVE
                                  WHERE COMPANY_CODE = P_COMPANY
                                  AND COMPANY_BRANCH_CODE = V_BRANCH
                                  AND FINANCE_CODE = P_FINANCE_CODE
                                  AND PROJECT_CODE = P_PROJECT_CODE
                                  AND COMPONENT_CODE = P_COMPONENT_CODE
                                  AND MNYR = P_MNYR
                                  GROUP BY COMPANY_BRANCH_CODE , SAMITY_CODE ,  MEMBER_ID , LOAN_CODE , DAFA_NO
                                  ;    
          
                  BEGIN
                               FOR M IN MTR1
          
                                      LOOP
                                          UPDATE  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION ------------- MONTH TOTAL RECEIVABLE
                                          SET
                                              MONTH_TTL_RCVBLE_WSC = M.TTL_INST_AMT,
                                              MONTH_TTL_RCVBLE_PRN = M.TTL_INST_AMT_PRN
                                          WHERE  
                                          COMPANY_CODE = V_COMPANY  
                                              AND COMPANY_BRANCH_CODE = V_BRANCH
                                          AND MNYR = P_MNYR
                                          AND FINANCE_CODE = P_FINANCE_CODE
                                          AND PROJECT_CODE = P_PROJECT_CODE
                                          AND COMPONENT_CODE = P_COMPONENT_CODE
                                          AND SAMITY_CODE = M.SAMITY_CODE
                                          AND MEMBER_ID = M.MEMBER_ID
                                          AND LOAN_CODE = M.LOAN_CODE
                                          AND DAFA_NO = M.DAFA_NO
                                          ;
          
                                         COMMIT;
          
                                         -- DBMS_OUTPUT.PUT_LINE(V_DAY_OPN);
          
                                      END LOOP ;
          
          
                  END;

                  ------------------------------- RECOVERY MEMBER RECEIVABLE
                   BEGIN
          
                          DECLARE------------------------------------------- LOAN DETAILS
                                       CURSOR L1 IS
                                              SELECT   /*+ INDEX(PK_LOAN_BAL)*/ 
                                              COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , INSTALL_INTERVAL LOAN_TYPE
                                                      , LOAN_RECOVERY_FLAG , LOAN_RECOVERY_DATE
                                              FROM LOAN_BAL
                                              WHERE COMPANY_CODE = P_COMPANY
                                              AND COMPANY_BRANCH_CODE = V_BRANCH
                                              AND FINANCE_CODE = P_FINANCE_CODE
                                              AND PROJECT_CODE = P_PROJECT_CODE
                                              AND COMPONENT_CODE = P_COMPONENT_CODE
                                              ;
          
          
                          BEGIN
                                       FOR LD IN L1
          
                                              LOOP
                                                  UPDATE  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION
                                                  SET
                                                      LOAN_TYPE = LD.LOAN_TYPE,
                                                      RECOVERY_FLAG = LD.LOAN_RECOVERY_FLAG,
                                                      RECOVERY_DATE = LD.LOAN_RECOVERY_DATE
                                                      
                                                         ---------------------------------- CLOSING BALANCE   --------------------------------------- 15012025
                                                  ,  CLS_LOAN_WSC = OPENING_LOAN_WSC  - TOTAL_RECEIVED_WSC
                                                  ,  CLS_DUE_WSC = OPENING_DUE_WSC + RECEIVABLE_WSC - (REG_RCVD_WSC + DUE_RCVD_WSC + ADVANCE_ADJUST_WSC )
                                                  ,  CLS_ADV_WSC = ADV_RCVD_WSC
          
                                                  ,  CLS_LOAN_PRN = OPENING_LOAN_PRN  - TOTAL_RECEIVED_PRN
                                                  ,  CLS_DUE_PRN = OPENING_DUE_PRN + RECEIVABLE_PRN - (REG_RCVD_PRN + DUE_RCVD_PRN + ADVANCE_ADJ_PRN )
                                                  ,  CLS_ADV_PRN = ADV_RCVD_PRN 
          
          
                                                  WHERE  
                                                  COMPANY_CODE = V_COMPANY  
                                              AND COMPANY_BRANCH_CODE = V_BRANCH
                                                  AND MNYR = P_MNYR
                                                  AND FINANCE_CODE = P_FINANCE_CODE
                                                  AND PROJECT_CODE = P_PROJECT_CODE
                                                  AND COMPONENT_CODE = P_COMPONENT_CODE
                                                  AND SAMITY_CODE = LD.SAMITY_CODE
                                                  AND MEMBER_ID = LD.MEMBER_ID
                                                  AND LOAN_CODE = LD.LOAN_CODE
                                                  AND DAFA_NO = LD.DAFA_NO
                                                  ;
          
                                                 COMMIT;
          
                                                 -- DBMS_OUTPUT.PUT_LINE(V_DAY_OPN);
          
                                              END LOOP ;
                   
                              END;  
                      DECLARE -------------------------------------------- MONTH TOTAL RECEIVED AND RECOVERY MEMBER RECEIVABLE
                                       CURSOR RC1 IS
                                          SELECT   SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO ,
                                              NVL(CASE WHEN MONTH_TTL_RCVBLE_WSC > 0 AND TOTAL_RECEIVED_WSC <= MONTH_TTL_RCVBLE_WSC
                                                      THEN TOTAL_RECEIVED_WSC END,0) CUR_MONTH_REG_RCVD_WSC
                                          , NVL(CASE WHEN MONTH_TTL_RCVBLE_PRN > 0 AND TOTAL_RECEIVED_PRN <= MONTH_TTL_RCVBLE_PRN
                                                  THEN TOTAL_RECEIVED_PRN END,0) MONTH_TTL_RCVBLE_PRN
                                                  , LOAN_TYPE  , RECOVERY_FLAG , RECOVERY_DATE
                                                  ,  ADV_RCVD_WSC , MONTH_TTL_RCVBLE_WSC
          
                                           FROM
                                              (
                                              SELECT  /*+ INDEX(MF_LOAN_RDRA_PK)*/  SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , OPENING_LOAN_WSC , OPENING_DUE_WSC , OPENING_ADVANCE_WSC
                                                      , RECEIVABLE_WSC , TOTAL_RECEIVED_WSC , MONTH_TTL_RCVBLE_WSC
                                                      , RECEIVABLE_PRN , TOTAL_RECEIVED_PRN , MONTH_TTL_RCVBLE_PRN
                                                      , ADV_RCVD_WSC , ADV_RCVD_PRN
                                                      , LOAN_TYPE  , RECOVERY_FLAG , RECOVERY_DATE
                                              FROM MF_LOAN_REALIZATION
                                              WHERE 
                                              COMPANY_CODE = V_COMPANY  
                                              AND COMPANY_BRANCH_CODE = V_BRANCH
                                              AND FINANCE_CODE = P_FINANCE_CODE
                                              AND PROJECT_CODE = P_PROJECT_CODE
                                              AND COMPONENT_CODE = P_COMPONENT_CODE
                                              AND MNYR = P_MNYR
                                              )
                                              ;
          
          
                  BEGIN
                           FOR P IN RC1
          
                                  LOOP
                                          UPDATE  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION
                                          SET
                                              MONTH_TTL_REG_RCVD_WSC = P.CUR_MONTH_REG_RCVD_WSC,
                                              MONTH_TTL_REG_RCVD_PRN = P.MONTH_TTL_RCVBLE_PRN
                                         --    , RECEIVABLE_WSC = CASE WHEN P.LOAN_TYPE = 'O' AND  P.RECOVERY_FLAG IS NOT NULL THEN P.MONTH_TTL_RCVBLE_WSC END
                                           --  , REG_RCVD_WSC =  CASE WHEN P.LOAN_TYPE = 'O' AND  P.RECOVERY_FLAG IS NOT NULL THEN P.CUR_MONTH_REG_RCVD_WSC END
                                          --   , ADV_RCVD_WSC =  CASE WHEN P.LOAN_TYPE = 'O' AND  P.RECOVERY_FLAG IS NOT NULL AND ADV_RCVD_WSC > P.CUR_MONTH_REG_RCVD_WSC THEN ADV_RCVD_WSC - P.CUR_MONTH_REG_RCVD_WSC END
          
                                          WHERE  
                                          COMPANY_CODE = V_COMPANY  
                                          AND COMPANY_BRANCH_CODE = V_BRANCH
                                          AND MNYR = P_MNYR
                                          AND FINANCE_CODE = P_FINANCE_CODE
                                          AND PROJECT_CODE = P_PROJECT_CODE
                                          AND COMPONENT_CODE = P_COMPONENT_CODE
                                          AND SAMITY_CODE = P.SAMITY_CODE
                                          AND MEMBER_ID = P.MEMBER_ID
                                          AND LOAN_CODE = P.LOAN_CODE
                                          AND DAFA_NO = P.DAFA_NO
                                          ;
          
          
                                          IF P.LOAN_TYPE = 'O' AND P.MONTH_TTL_RCVBLE_WSC > 0  AND P.RECOVERY_FLAG IS NOT NULL THEN
          
                                              UPDATE  /*+ INDEX(MF_LOAN_RDRA_PK)*/ MF_LOAN_REALIZATION
                                              SET
                                              RECEIVABLE_WSC = P.MONTH_TTL_RCVBLE_WSC
                                              , REG_RCVD_WSC = P.MONTH_TTL_RCVBLE_WSC
                                              , ADV_RCVD_WSC  = CASE WHEN  ADV_RCVD_WSC > P.CUR_MONTH_REG_RCVD_WSC THEN ADV_RCVD_WSC - P.CUR_MONTH_REG_RCVD_WSC END
                                              , TOTAL_RECEIVED_WSC = P.MONTH_TTL_RCVBLE_WSC    --CASE WHEN P.MONTH_TTL_RCVBLE_WSC > 0 THEN  P.MONTH_TTL_RCVBLE_WSC END
                                               WHERE
                                                  COMPANY_CODE = V_COMPANY  
                                              AND COMPANY_BRANCH_CODE = V_BRANCH
                                              AND MNYR = P_MNYR
                                              AND FINANCE_CODE = P_FINANCE_CODE
                                              AND PROJECT_CODE = P_PROJECT_CODE
                                              AND COMPONENT_CODE = P_COMPONENT_CODE
                                              AND SAMITY_CODE = P.SAMITY_CODE
                                              AND MEMBER_ID = P.MEMBER_ID
                                              AND LOAN_CODE = P.LOAN_CODE
                                              AND DAFA_NO = P.DAFA_NO
                                            --  AND  LOAN_TYPE = '0'
                                        --      AND RECOVERY_FLAG = 'Y'
                                              ;
          
                                          END IF;
          
                                         COMMIT;
          
          
                                  END LOOP ;
          
          
                              END;
          
          
          
                          END; -------------- END RECOVERY MEMBER RECEIVABLE

                     -------------------------------------------- UPDATE OTR DAILY INFORMATION FOR PRESERVATION OR HISTORY ------------------------- 12.03.2025----
              DECLARE
              
              
              BEGIN 
              
                DECLARE ----------------------------------------------- UPDATE BRANCH WISE OTR HISTORY DATA

                    CURSOR C1 IS
                    SELECT 
                       COMPANY_CODE , COMPANY_BRANCH_CODE , LAST_CLS_DATE,  MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE,
                       NVL(SUM(RECEIVABLE_WSC),0) ACD_RECEIVABLE_WSC, NVL(SUM(DUE_RCVD_WSC),0) ACD_DUE_RCVD_WSC, NVL(SUM(REG_RCVD_WSC),0) ACD_REG_RCVD_WSC, NVL(SUM(ADV_RCVD_WSC),0)ACD_ADV_RCVD_WSC,
                       NVL(SUM(ADVANCE_ADJUST_WSC),0)ACD_ADV_ADJUST_WSC,
                       NVL(SUM(TOTAL_RECEIVED_WSC),0) ACD_TOTAL_RECEIVED_WSC,
                       ROUND((NVL(SUM(REG_RCVD_WSC),0) + NVL(SUM(ADVANCE_ADJUST_WSC),0)) / DECODE(NVL(SUM(RECEIVABLE_WSC),0), 0 , .00001, SUM(RECEIVABLE_WSC)),4) * 100 ACD_OTR_WSC,
                       
                       NVL(SUM(RECEIVABLE_PRN),0) ACD_RECEIVABLE_PRN, NVL(SUM(DUE_RCVD_PRN),0) ACD_DUE_RCVD_PRN, NVL(SUM(REG_RCVD_PRN),0) ACD_REG_RCVD_PRN, NVL(SUM(ADV_RCVD_PRN),0)ACD_ADV_RCVD_PRN,
                       NVL(SUM(ADVANCE_ADJ_PRN),0)ACD_ADV_ADJ_PRN,
                       NVL(SUM(TOTAL_RECEIVED_PRN),0) ACD_TOTAL_RECEIVED_PRN,
                       ROUND((NVL(SUM(REG_RCVD_PRN),0) + NVL(SUM(ADVANCE_ADJ_PRN),0)) / DECODE(NVL(SUM(RECEIVABLE_PRN),0), 0 , .00001, SUM(RECEIVABLE_PRN)),4) * 100 ACD_OTR_PRN
                    FROM  MF_LOAN_REALIZATION
                    WHERE COMPANY_CODE = V_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND MNYR = P_MNYR
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    GROUP BY COMPANY_CODE , COMPANY_BRANCH_CODE , LAST_CLS_DATE, MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE
                    ;
            
                    BEGIN
                    
                            FOR R IN C1
                            LOOP
                                    UPDATE MF_OTR_INFO_BRANCH_DAY
                                    SET ACD_RECEIVABLE_WSC = R.ACD_RECEIVABLE_WSC, ACD_TOTAL_RECEIVED_WSC = R.ACD_TOTAL_RECEIVED_WSC
                                        , ACD_DUE_RCVD_WSC = R.ACD_DUE_RCVD_WSC, ACD_REG_RCVD_WSC = R.ACD_REG_RCVD_WSC, ACD_ADV_RCVD_WSC = R.ACD_ADV_RCVD_WSC
                                        , ACD_ADV_ADJUST_WSC = R.ACD_ADV_RCVD_WSC , ACD_OTR_WSC = R.ACD_OTR_WSC
                                        
                                        , ACD_RECEIVABLE_PRN = R.ACD_RECEIVABLE_PRN, ACD_TOTAL_RECEIVED_PRN = R.ACD_TOTAL_RECEIVED_PRN
                                        , ACD_DUE_RCVD_PRN = R.ACD_DUE_RCVD_PRN, ACD_REG_RCVD_PRN = R.ACD_REG_RCVD_PRN, ACD_ADV_RCVD_PRN = R.ACD_ADV_RCVD_PRN
                                        , ACD_ADV_ADJ_PRN = R.ACD_ADV_ADJ_PRN , ACD_OTR_PRN = R.ACD_OTR_PRN
                                        
                                        , UPD_BY = USER, UPD_DATE = SYSDATE
                                    WHERE COMPANY_CODE = V_COMPANY
                                    AND COMPANY_BRANCH_CODE = V_BRANCH
                                    AND FINANCE_CODE = P_FINANCE_CODE
                                    AND PROJECT_CODE = P_PROJECT_CODE
                                    AND COMPONENT_CODE = P_COMPONENT_CODE
                                    AND MNYR = P_MNYR
                                    AND TRANSACTION_DAY = P_CLOSE_DATE
                                    ;
                                    
                                    COMMIT;
                                    
                            
                            END LOOP;
                    
                    END;


                    DECLARE ----------------------------------------------- UPDATE Loan Code WISE OTR HISTORY DATA

                    CURSOR C1 IS
                    SELECT 
                       COMPANY_CODE , COMPANY_BRANCH_CODE , LAST_CLS_DATE,  MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE,LOAN_CODE,
                       NVL(SUM(RECEIVABLE_WSC),0) ACD_RECEIVABLE_WSC, NVL(SUM(DUE_RCVD_WSC),0) ACD_DUE_RCVD_WSC, NVL(SUM(REG_RCVD_WSC),0) ACD_REG_RCVD_WSC, NVL(SUM(ADV_RCVD_WSC),0)ACD_ADV_RCVD_WSC,
                       NVL(SUM(ADVANCE_ADJUST_WSC),0)ACD_ADV_ADJUST_WSC,
                       NVL(SUM(TOTAL_RECEIVED_WSC),0) ACD_TOTAL_RECEIVED_WSC,
                       ROUND((NVL(SUM(REG_RCVD_WSC),0) + NVL(SUM(ADVANCE_ADJUST_WSC),0)) / DECODE(NVL(SUM(RECEIVABLE_WSC),0), 0 , .00001, SUM(RECEIVABLE_WSC)),4) * 100 ACD_OTR_WSC,
                       
                       NVL(SUM(RECEIVABLE_PRN),0) ACD_RECEIVABLE_PRN, NVL(SUM(DUE_RCVD_PRN),0) ACD_DUE_RCVD_PRN, NVL(SUM(REG_RCVD_PRN),0) ACD_REG_RCVD_PRN, NVL(SUM(ADV_RCVD_PRN),0)ACD_ADV_RCVD_PRN,
                       NVL(SUM(ADVANCE_ADJ_PRN),0)ACD_ADV_ADJ_PRN,
                       NVL(SUM(TOTAL_RECEIVED_PRN),0) ACD_TOTAL_RECEIVED_PRN,
                       ROUND((NVL(SUM(REG_RCVD_PRN),0) + NVL(SUM(ADVANCE_ADJ_PRN),0)) / DECODE(NVL(SUM(RECEIVABLE_PRN),0), 0 , .00001, SUM(RECEIVABLE_PRN)),4) * 100 ACD_OTR_PRN
                    FROM  MF_LOAN_REALIZATION
                    WHERE COMPANY_CODE = V_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND MNYR = P_MNYR
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    GROUP BY COMPANY_CODE , COMPANY_BRANCH_CODE , LAST_CLS_DATE, MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE, LOAN_CODE
                    HAVING NVL(SUM(RECEIVABLE_WSC),0) > 0
                    ;
            
                    BEGIN
                    
                            FOR R IN C1
                            LOOP
                                    UPDATE MF_OTR_INFO_COMP_DAY
                                    SET ACD_RECEIVABLE_WSC = R.ACD_RECEIVABLE_WSC, ACD_TOTAL_RECEIVED_WSC = R.ACD_TOTAL_RECEIVED_WSC
                                        , ACD_DUE_RCVD_WSC = R.ACD_DUE_RCVD_WSC, ACD_REG_RCVD_WSC = R.ACD_REG_RCVD_WSC, ACD_ADV_RCVD_WSC = R.ACD_ADV_RCVD_WSC
                                        , ACD_ADV_ADJUST_WSC = R.ACD_ADV_RCVD_WSC , ACD_OTR_WSC = R.ACD_OTR_WSC
                                        
                                        , ACD_RECEIVABLE_PRN = R.ACD_RECEIVABLE_PRN, ACD_TOTAL_RECEIVED_PRN = R.ACD_TOTAL_RECEIVED_PRN
                                        , ACD_DUE_RCVD_PRN = R.ACD_DUE_RCVD_PRN, ACD_REG_RCVD_PRN = R.ACD_REG_RCVD_PRN, ACD_ADV_RCVD_PRN = R.ACD_ADV_RCVD_PRN
                                        , ACD_ADV_ADJ_PRN = R.ACD_ADV_ADJ_PRN , ACD_OTR_PRN = R.ACD_OTR_PRN
                                        
                                        , UPD_BY = USER, UPD_DATE = SYSDATE
                                    WHERE COMPANY_CODE = V_COMPANY
                                    AND COMPANY_BRANCH_CODE = V_BRANCH
                                    AND FINANCE_CODE = P_FINANCE_CODE
                                    AND PROJECT_CODE = P_PROJECT_CODE
                                    AND COMPONENT_CODE = P_COMPONENT_CODE
                                    AND MNYR = P_MNYR
                                    AND TRANSACTION_DAY = P_CLOSE_DATE
                                    AND LOAN_CODE = R.LOAN_CODE
                                    ;
                                    
                                    COMMIT;
                                    
                            
                            END LOOP;
                    
                    END;

                    DECLARE ----------------------------------------------- UPDATE CO Code WISE OTR HISTORY DATA

                    CURSOR C1 IS
                    SELECT 
                    L.COMPANY_CODE , L.COMPANY_BRANCH_CODE , L.LAST_CLS_DATE,  L.MNYR, L.FINANCE_CODE, L.PROJECT_CODE, L.COMPONENT_CODE, S.CO_ID,
                    NVL(SUM(RECEIVABLE_WSC),0) ACD_RECEIVABLE_WSC, NVL(SUM(DUE_RCVD_WSC),0) ACD_DUE_RCVD_WSC, NVL(SUM(REG_RCVD_WSC),0) ACD_REG_RCVD_WSC, NVL(SUM(ADV_RCVD_WSC),0)ACD_ADV_RCVD_WSC,
                    NVL(SUM(ADVANCE_ADJUST_WSC),0)ACD_ADV_ADJUST_WSC,
                    NVL(SUM(TOTAL_RECEIVED_WSC),0) ACD_TOTAL_RECEIVED_WSC,
                    ROUND((NVL(SUM(REG_RCVD_WSC),0) + NVL(SUM(ADVANCE_ADJUST_WSC),0)) / DECODE(NVL(SUM(RECEIVABLE_WSC),0), 0 , .00001, SUM(RECEIVABLE_WSC)),4) * 100 ACD_OTR_WSC,
                    NVL(SUM(RECEIVABLE_PRN),0) ACD_RECEIVABLE_PRN, NVL(SUM(DUE_RCVD_PRN),0) ACD_DUE_RCVD_PRN, NVL(SUM(REG_RCVD_PRN),0) ACD_REG_RCVD_PRN, NVL(SUM(ADV_RCVD_PRN),0)ACD_ADV_RCVD_PRN,
                    NVL(SUM(ADVANCE_ADJ_PRN),0)ACD_ADV_ADJ_PRN,
                    NVL(SUM(TOTAL_RECEIVED_PRN),0) ACD_TOTAL_RECEIVED_PRN,
                    ROUND((NVL(SUM(REG_RCVD_PRN),0) + NVL(SUM(ADVANCE_ADJ_PRN),0)) / DECODE(NVL(SUM(RECEIVABLE_PRN),0), 0 , .00001, SUM(RECEIVABLE_PRN)),4) * 100 ACD_OTR_PRN
             
                    FROM  MF_LOAN_REALIZATION L
                    JOIN  
                            (
                            SELECT COMPANY_CODE, COMPANY_BRANCH_CODE,  FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE,  SAMITY_CODE, FW_ID CO_ID
                            FROM SAMITY_INFO
                            WHERE COMPANY_CODE = '0133'
                            AND COMPANY_BRANCH_CODE = '003'
                            ) S
                        ON
                            (
                                L.COMPANY_CODE = S.COMPANY_CODE
                            AND L.COMPANY_BRANCH_CODE = S.COMPANY_BRANCH_CODE
                            AND L.FINANCE_CODE = S.FINANCE_CODE
                            AND L.PROJECT_CODE = S.PROJECT_CODE
                            AND L.COMPONENT_CODE = S.COMPONENT_CODE
                            AND L.SAMITY_CODE = S.SAMITY_CODE
                            )
                    WHERE L.COMPANY_CODE = V_COMPANY
                    AND L.COMPANY_BRANCH_CODE = V_BRANCH
                    AND L.MNYR = P_MNYR
                    AND L.FINANCE_CODE = P_FINANCE_CODE
                    AND L.PROJECT_CODE = P_PROJECT_CODE
                    AND L.COMPONENT_CODE = P_COMPONENT_CODE
                    GROUP BY L.COMPANY_CODE , L.COMPANY_BRANCH_CODE , L.LAST_CLS_DATE, L.MNYR, L.FINANCE_CODE, L.PROJECT_CODE, L.COMPONENT_CODE, S.CO_ID
                    HAVING NVL(SUM(RECEIVABLE_WSC),0) > 0
                    ;
            
                    BEGIN
                    
                            FOR R IN C1
                            LOOP
                                    UPDATE MF_OTR_INFO_CO_DAY
                                    SET ACD_RECEIVABLE_WSC = R.ACD_RECEIVABLE_WSC, ACD_TOTAL_RECEIVED_WSC = R.ACD_TOTAL_RECEIVED_WSC
                                        , ACD_DUE_RCVD_WSC = R.ACD_DUE_RCVD_WSC, ACD_REG_RCVD_WSC = R.ACD_REG_RCVD_WSC, ACD_ADV_RCVD_WSC = R.ACD_ADV_RCVD_WSC
                                        , ACD_ADV_ADJUST_WSC = R.ACD_ADV_RCVD_WSC , ACD_OTR_WSC = R.ACD_OTR_WSC
                                        
                                        , ACD_RECEIVABLE_PRN = R.ACD_RECEIVABLE_PRN, ACD_TOTAL_RECEIVED_PRN = R.ACD_TOTAL_RECEIVED_PRN
                                        , ACD_DUE_RCVD_PRN = R.ACD_DUE_RCVD_PRN, ACD_REG_RCVD_PRN = R.ACD_REG_RCVD_PRN, ACD_ADV_RCVD_PRN = R.ACD_ADV_RCVD_PRN
                                        , ACD_ADV_ADJ_PRN = R.ACD_ADV_ADJ_PRN , ACD_OTR_PRN = R.ACD_OTR_PRN
                                        
                                        , UPD_BY = USER, UPD_DATE = SYSDATE
                                    WHERE COMPANY_CODE = V_COMPANY
                                    AND COMPANY_BRANCH_CODE = V_BRANCH
                                    AND FINANCE_CODE = P_FINANCE_CODE
                                    AND PROJECT_CODE = P_PROJECT_CODE
                                    AND COMPONENT_CODE = P_COMPONENT_CODE
                                    AND MNYR = P_MNYR
                                    AND TRANSACTION_DAY = P_CLOSE_DATE
                                    AND CO_ID = R.CO_ID
                                    ;
                                    
                                    COMMIT;
                                    
                            
                            END LOOP;
                    
                    END;
              
              
              END;----------------------------------- END OF OTR HISTORY DATA UDPATE
          
          
              END;
          
          END;
