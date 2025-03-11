# PROC_LOAN_REALIZATION_DAY

  create or replace PROCEDURE PROC_LOAN_REALIZATION_DAY (
   
                P_COMPANY           IN VARCHAR2,
                P_BRANCH            IN VARCHAR2,
                P_FINANCE_CODE	    IN VARCHAR2,
                P_PROJECT_CODE	    IN VARCHAR2,
                P_COMPONENT_CODE	IN VARCHAR2,
                P_MNYR              IN VARCHAR2,
                P_TRANS_DATE        IN DATE,
                P_USER              IN VARCHAR2
            )
    IS BEGIN

    DECLARE

        V_MNYR          VARCHAR2(7) := P_MNYR;
        V_TANSA_DATE    DATE        := P_TRANS_DATE;
        V_WKYR          VARCHAR2(7) := GET_WEEK_STARTYR(V_TANSA_DATE);
        V_BRANCH        VARCHAR2(4) := P_BRANCH;

    BEGIN
           BEGIN --- INSERT DAY DATA

           DELETE MF_LOAN_REALIZATION_DAY
           WHERE COMPANY_BRANCH_CODE = V_BRANCH
          -- AND MNYR != V_MNYR
           --AND WKYR = V_WKYR
           --AND TRANS_DAY = P_TRANS_DATE
           ;

           COMMIT;
           /*
           DELETE MF_LOAN_REALIZATION_DAY
           WHERE COMPANY_BRANCH_CODE = V_BRANCH
           AND MNYR = V_MNYR
           --AND WKYR = V_WKYR
            AND TRANS_DAY = P_TRANS_DATE
           ;

           COMMIT;
            */
            
            INSERT INTO MF_LOAN_REALIZATION_DAY
            (
            COMPANY_CODE , COMPANY_BRANCH_CODE , FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE, MNYR , WKYR, TRANS_DAY,
            SAMITY_CODE ,MEMBER_ID ,LOAN_CODE ,DAFA_NO ,
            OPENING_LOAN_WSC ,OPENING_DUE_WSC ,OPENING_ADVANCE_WSC ,
            RECEIVABLE_WSC ,TOTAL_RECEIVED_WSC ,DUE_RCVD_WSC ,REG_RCVD_WSC ,ADV_RCVD_WSC ,
            OPENING_LOAN_PRN ,OPENING_DUE_PRN ,OPENING_ADVANCE_PRN ,
            RECEIVABLE_PRN ,TOTAL_RECEIVED_PRN ,DUE_RCVD_PRN ,REG_RCVD_PRN , ADV_RCVD_PRN ,
            UPDATE_BY ,UPDATE_TIME ,
            ADVANCE_ADJUST_WSC ,ADVANCE_ADJ_PRN ,
            MONTH_TTL_RCVBLE_WSC ,MONTH_TTL_RCVBLE_PRN ,MONTH_TTL_REG_RCVD_WSC ,MONTH_TTL_REG_RCVD_PRN ,
            LOAN_TYPE ,RECOVERY_FLAG ,RECOVERY_DATE ,
            CLS_LOAN_WSC ,CLS_DUE_WSC ,CLS_ADV_WSC ,
            CLS_LOAN_PRN ,CLS_DUE_PRN ,CLS_ADV_PRN ,
            LLP_AGE_CODE_OPN ,LLP_PCT_OPN ,LLP_DAYS_OPN ,
            INSTALL_AMT ,LLP_CM_DAYS ,LLP_CLASS_OPN ,
            CM_DUE_WSC ,CM_DUE_PRN ,LLP_CUR_DAYS ,LLP_CUR_CLASS ,
            DISBURSE_DATE ,DISBURSE_AMT ,NEW_DISBURSE_FLAG ,
            TR_OUT_FLAG ,TR_IN_FLAG ,CO_ID ,DISBURSE_AMT_WSC 

            )
            (
            SELECT 
            P_COMPANY , P_BRANCH , P_FINANCE_CODE, P_PROJECT_CODE, P_COMPONENT_CODE, MNYR ,  V_WKYR, V_TANSA_DATE,
            SAMITY_CODE ,MEMBER_ID ,LOAN_CODE ,DAFA_NO ,
            OPENING_LOAN_WSC ,OPENING_DUE_WSC ,OPENING_ADVANCE_WSC ,
            RECEIVABLE_WSC ,TOTAL_RECEIVED_WSC ,DUE_RCVD_WSC ,REG_RCVD_WSC ,ADV_RCVD_WSC ,
            OPENING_LOAN_PRN ,OPENING_DUE_PRN ,OPENING_ADVANCE_PRN ,
            RECEIVABLE_PRN ,TOTAL_RECEIVED_PRN ,DUE_RCVD_PRN ,REG_RCVD_PRN , ADV_RCVD_PRN ,
            P_USER ,SYSDATE ,
            ADVANCE_ADJUST_WSC ,ADVANCE_ADJ_PRN ,
            MONTH_TTL_RCVBLE_WSC ,MONTH_TTL_RCVBLE_PRN ,MONTH_TTL_REG_RCVD_WSC ,MONTH_TTL_REG_RCVD_PRN ,
            LOAN_TYPE ,RECOVERY_FLAG ,RECOVERY_DATE ,
            CLS_LOAN_WSC ,CLS_DUE_WSC ,CLS_ADV_WSC ,
            CLS_LOAN_PRN ,CLS_DUE_PRN ,CLS_ADV_PRN ,
            LLP_AGE_CODE_OPN ,LLP_PCT_OPN ,LLP_DAYS_OPN ,
            INSTALL_AMT ,LLP_CM_DAYS ,LLP_CLASS_OPN ,
            CM_DUE_WSC ,CM_DUE_PRN ,LLP_CUR_DAYS ,LLP_CUR_CLASS ,
            DISBURSE_DATE ,DISBURSE_AMT ,NEW_DISBURSE_FLAG ,
            TR_OUT_FLAG ,TR_IN_FLAG ,CO_ID ,DISBURSE_AMT_WSC 
            FROM MF_LOAN_REALIZATION
            WHERE MNYR = V_MNYR
            AND COMPANY_BRANCH_CODE = V_BRANCH

            );

            COMMIT;


        END;

        DECLARE

            CURSOR C1 IS

            SELECT  COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO 
            , OPENING_LOAN_WSC , OPENING_DUE_WSC , OPENING_ADVANCE_WSC
            , RECEIVABLE_WSC , TOTAL_RECEIVED_WSC
            ----------------------------------------------------------------------------------------------------------- TODAY'S OTR WSC
            ,  NVL(CASE  WHEN TODAYS_RCVBLE > 0 AND  TD_TTL_RCVD <= TODAYS_RCVBLE THEN  TD_TTL_RCVD  
                        WHEN TODAYS_RCVBLE > 0 AND  TD_TTL_RCVD > TODAYS_RCVBLE THEN  TODAYS_RCVBLE
                    END,0) TD_REG_RCVD_WSC
            
             , NVL(CASE  WHEN OPENING_DUE_WSC > 0 AND TD_TTL_RCVD >=  TODAYS_RCVBLE + OPENING_DUE_WSC THEN OPENING_DUE_WSC
                    WHEN OPENING_DUE_WSC > 0 AND TD_TTL_RCVD > TODAYS_RCVBLE AND TD_TTL_RCVD <=  TODAYS_RCVBLE + OPENING_DUE_WSC 
                            THEN TD_TTL_RCVD - TODAYS_RCVBLE
                    END, 0) TD_DEU_RCVD_WSC
             , NVL(CASE 
                    WHEN TD_TTL_RCVD > OPENING_DUE_WSC + TODAYS_RCVBLE THEN TD_TTL_RCVD  - (OPENING_DUE_WSC + TODAYS_RCVBLE)
                    WHEN OPENING_DUE_WSC = 0 AND TD_TTL_RCVD > TODAYS_RCVBLE THEN TD_TTL_RCVD - TODAYS_RCVBLE
                    END,0) TD_ADV_RCVD_WSC
                    
             , NVL(CASE 
                    WHEN OPENING_ADVANCE_WSC > 0 AND  TD_TTL_RCVD < TODAYS_RCVBLE AND OPENING_ADVANCE_WSC <= TODAYS_RCVBLE  - TD_TTL_RCVD 
                            THEN OPENING_ADVANCE_WSC
                     WHEN OPENING_ADVANCE_WSC > 0 AND TD_TTL_RCVD < TODAYS_RCVBLE AND OPENING_ADVANCE_WSC > TODAYS_RCVBLE  - TD_TTL_RCVD 
                            THEN TODAYS_RCVBLE - TD_TTL_RCVD
                                                                    --TODAYS_RCVBLE
                     WHEN  TODAYS_RCVBLE > 0 AND TD_TTL_RCVD = 0 AND RECEIVABLE_WSC <= PRV_TTL_RCVD THEN  TODAYS_RCVBLE -- CORRECTION FOR INCORRECT ADVANCE ADJUST AMOUNT 30112023
                     --WHEN  TODAYS_RCVBLE > 0 AND TD_TTL_RCVD > 0 AND TD_TTL_RCVD < TODAYS_RCVBLE  AND TODAYS_RCVBLE <= PRV_TTL_RCVD THEN  TODAYS_RCVBLE
                      -- IF  ADVANCE BALANCE CREATE IN THE MONTH
                     WHEN NVL(CLS_ADV_WSC,0) > 1  AND  TD_TTL_RCVD < TODAYS_RCVBLE_PRN AND NVL(CLS_ADV_WSC,0) <= TODAYS_RCVBLE  - TD_TTL_RCVD 
                            THEN NVL(CLS_ADV_WSC,0)
                    END,0) TD_ADVANCE_ADJUST_WSC
            ------------------------------------------------------------------------------------------------------------------------------ TODAYS'S OTR PRN
            
              ,  NVL(CASE  WHEN TODAYS_RCVBLE_PRN > 0 AND  TD_TTL_RCVD_PRN <= TODAYS_RCVBLE_PRN THEN  TD_TTL_RCVD_PRN  
                        WHEN TODAYS_RCVBLE_PRN > 0 AND  TD_TTL_RCVD_PRN > TODAYS_RCVBLE_PRN THEN  TODAYS_RCVBLE_PRN
                    END,0) TD_REG_RCVD_PRN
            
             , NVL(CASE  WHEN OPENING_LOAN_PRN > 0 AND TD_TTL_RCVD_PRN >=  TODAYS_RCVBLE_PRN + OPENING_LOAN_PRN THEN OPENING_LOAN_PRN
                    WHEN OPENING_LOAN_PRN > 0 AND TD_TTL_RCVD_PRN > TODAYS_RCVBLE_PRN AND TD_TTL_RCVD_PRN <=  TODAYS_RCVBLE_PRN + OPENING_LOAN_PRN 
                            THEN TD_TTL_RCVD_PRN - TODAYS_RCVBLE_PRN
                    END, 0) TD_DEU_RCVD_PRN
        
        
        
            , NVL(CASE 
                    WHEN OPENING_ADVANCE_PRN > 0 AND  TD_TTL_RCVD_PRN < TODAYS_RCVBLE_PRN AND OPENING_ADVANCE_PRN <= TODAYS_RCVBLE_PRN  - TD_TTL_RCVD_PRN 
                            THEN OPENING_ADVANCE_PRN
                     WHEN OPENING_ADVANCE_PRN > 0 AND TD_TTL_RCVD_PRN < TODAYS_RCVBLE_PRN AND OPENING_ADVANCE_PRN > TODAYS_RCVBLE_PRN  - TD_TTL_RCVD_PRN 
                            THEN TODAYS_RCVBLE_PRN - TD_TTL_RCVD_PRN
                                                                    --TODAYS_RCVBLE
                     WHEN  TODAYS_RCVBLE > 0 AND TD_TTL_RCVD = 0 AND RECEIVABLE_WSC <= PRV_TTL_RCVD THEN  TODAYS_RCVBLE_PRN -- CORRECTION FOR INCORRECT ADVANCE ADJUST AMOUNT 30112023
                     --WHEN  TODAYS_RCVBLE > 0 AND TD_TTL_RCVD > 0 AND TD_TTL_RCVD < TODAYS_RCVBLE  AND TODAYS_RCVBLE <= PRV_TTL_RCVD THEN  TODAYS_RCVBLE
                    -- IF  ADVANCE BALANCE CREATE IN THE MONTH
                     WHEN NVL(CLS_ADV_PRN,0) > 1  AND  TD_TTL_RCVD_PRN < TODAYS_RCVBLE_PRN AND NVL(CLS_ADV_PRN,0) <= TODAYS_RCVBLE_PRN  - TD_TTL_RCVD_PRN 
                            THEN NVL(CLS_ADV_PRN,0)
                    END,0) TD_ADVANCE_ADJUST_PRN
                    
                    
            ------------------------------------------------------------------------------------------------------------
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
            , NVL(CASE 
                    WHEN OPENING_ADVANCE_WSC > 0 AND  TOTAL_RECEIVED_WSC < RECEIVABLE_WSC AND OPENING_ADVANCE_WSC <= RECEIVABLE_WSC  - TOTAL_RECEIVED_WSC 
                            THEN OPENING_ADVANCE_WSC
                                
                     WHEN OPENING_ADVANCE_WSC > 0 AND TOTAL_RECEIVED_WSC < RECEIVABLE_WSC AND OPENING_ADVANCE_WSC > RECEIVABLE_WSC  - TOTAL_RECEIVED_WSC 
                            THEN RECEIVABLE_WSC - TOTAL_RECEIVED_WSC
                    END,0) ADVANCE_ADJUST_WSC_NEW
            -----------------------------------------------------------------------------------------
              , RECEIVABLE_PRN ,  TOTAL_RECEIVED_PRN 
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
             , NVL(CASE 
                                WHEN OPENING_ADVANCE_PRN > 0 AND  TOTAL_RECEIVED_PRN < RECEIVABLE_PRN AND OPENING_ADVANCE_PRN <= RECEIVABLE_PRN  - TOTAL_RECEIVED_PRN 
                                        THEN OPENING_ADVANCE_PRN
                                 WHEN OPENING_ADVANCE_PRN > 0 AND TOTAL_RECEIVED_PRN < RECEIVABLE_PRN AND OPENING_ADVANCE_PRN > RECEIVABLE_PRN  - TOTAL_RECEIVED_PRN 
                                        THEN RECEIVABLE_PRN - TOTAL_RECEIVED_PRN
                                END,0) ADVANCE_ADJ_PRN
            -----------------------------------------------------------------------------------------------------------------------------                                
            , TODAYS_RCVBLE , TD_TTL_RCVD, REBATE_AMT
            , TODAYS_RCVBLE_PRN, TD_TTL_RCVD_PRN
            
            FROM
                (
                SELECT  T.COMPANY_BRANCH_CODE ,  T.SAMITY_CODE , T.MEMBER_ID,  T.LOAN_CODE  , T.DAFA_NO
                        , B.OPENING_LOAN_WSC , B.OPENING_DUE_WSC , B.OPENING_ADVANCE_WSC
                        , NVL(R.INSTALL_AMT,0) TODAYS_RCVBLE , NVL(R.PRN_AMT,0) TODAYS_RCVBLE_PRN
                            ---- CHANGE ON 22_02_24 FOR NOT ADD ON CURRENT DATE MONTHLY LOAN INSTALL 
             /*               
                        , (CASE WHEN B.LOAN_TYPE = 'W' THEN NVL(B.RECEIVABLE_WSC,0) + NVL(R.INSTALL_AMT,0) ELSE NVL(B.RECEIVABLE_WSC,0) END) RECEIVABLE_WSC  
                        , (CASE WHEN B.LOAN_TYPE = 'W' THEN NVL(B.RECEIVABLE_PRN,0) + NVL(R.PRN_AMT,0) ELSE NVL(B.RECEIVABLE_PRN,0) END) RECEIVABLE_PRN         
              */
                        , ( NVL(B.RECEIVABLE_WSC,0) + NVL(R.INSTALL_AMT,0)) RECEIVABLE_WSC  
                        , ( NVL(B.RECEIVABLE_PRN,0) + NVL(R.PRN_AMT,0)) RECEIVABLE_PRN  
                        
                        --, TOTAL_RECEIVED_WSC TILL_DAY_RCVD_WSC
                        ,  (NVL(T.TOTAL_RCVD_CLC,0) + NVL(T.TOTAL_IRG_RCVD,0) + NVL(T.TOTAL_ADJ_AMT,0) + NVL(T.TOTAL_INS_ADJUST,0)) TD_TTL_RCVD
                        , (NVL(T.TOTAL_RCVD_CLC,0) + NVL(T.TOTAL_IRG_RCVD,0) + NVL(T.TOTAL_ADJ_AMT,0) + NVL(T.TOTAL_INS_ADJUST,0)) + NVL(TOTAL_RECEIVED_WSC,0)  TOTAL_RECEIVED_WSC
                        , NVL(TOTAL_RECEIVED_WSC,0) PRV_TTL_RCVD
                        , OPENING_LOAN_PRN ,OPENING_DUE_PRN ,OPENING_ADVANCE_PRN 
                        , (NVL(T.TOTAL_RCVD_PRN_CLC,0) + NVL(T.TOTAL_IRG_RCVD_PRN,0) + NVL(T.TOTAL_ADJUST_PRN,0) + NVL(T.INS_ADJ_PRN,0)) TD_TTL_RCVD_PRN
                        , (NVL(T.TOTAL_RCVD_PRN_CLC,0) + NVL(T.TOTAL_IRG_RCVD_PRN,0) + NVL(T.TOTAL_ADJUST_PRN,0) + NVL(T.INS_ADJ_PRN,0)) + NVL(TOTAL_RECEIVED_PRN,0)  TOTAL_RECEIVED_PRN
                        , REBATE_AMT , CLS_ADV_WSC, CLS_ADV_PRN
                FROM
                    (
                    SELECT COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE  , DAFA_NO
                            
                             , SUM(TTL_CLC_RCVD) TOTAL_RCVD_CLC, SUM(TTL_CLC_PRN_RCVD) TOTAL_RCVD_PRN_CLC
                             , SUM(TTL_IRG_RCVD) TOTAL_IRG_RCVD, SUM(TTL_IRG_RCVD_PRN) TOTAL_IRG_RCVD_PRN
                             , SUM(TTL_CLC_RCVD) + SUM(TTL_IRG_RCVD) TOTAL_CASH_RCVD
                             , SUM(TTL_CLC_PRN_RCVD) + SUM(TTL_IRG_RCVD_PRN) TOTAL_CASH_RCVD_PRN
                             , SUM(ADJUST_AMT) TOTAL_ADJ_AMT , SUM(ADJUST_AMT_PRN) TOTAL_ADJUST_PRN
                             , SUM(TTL_INS_ADJUST) TOTAL_INS_ADJUST, SUM(INS_ADJUST_PRN) INS_ADJ_PRN
                             , SUM(INS_ADJUST_SC) INS_ADJ_SC
                             , NVL(SUM(CLC_REBATE_AMT),0) + NVL(SUM(IRG_RBT_AMT),0) + NVL(SUM(ADJ_REBATE_AMT),0) REBATE_AMT 

                FROM
                    (
                    SELECT C.COMPANY_BRANCH_CODE ,  C.SAMITY_CODE , C.MEMBER_ID,  C.LOAN_CODE , C.DAFA_NO
                                    , 0 TTL_DISBURSE, 0 TTL_LOAN_FEE , 0 TTL_INS_AMT , 0 TTL_LIVE_STK_AMT
                                    , TTL_CLC_RCVD , TTL_CLC_PRN_RCVD, CLC_REBATE_AMT
                                    , 0 TTL_IRG_RCVD , 0 TTL_IRG_RCVD_PRN, 0 IRG_RBT_AMT
                                    , 0 ADJUST_AMT , 0 ADJUST_AMT_PRN, 0 ADJUST_AMT_SC, 0 ADJ_REBATE_AMT
                                    , 0 TTL_INS_ADJUST, 0 INS_ADJUST_PRN , 0 INS_ADJUST_SC, 0 INS_REBATE_AMT
                                    , 0 AMOUNT_WO
                            FROM
                                (
                                SELECT    COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                                        , NVL(SUM(TTL_INSTALL_AMT_RCVD),0) TTL_CLC_RCVD 
                                        , NVL(SUM(AMOUNT_RCVD_PRN),0)  TTL_CLC_PRN_RCVD --, AMOUNT_RCVD_SC
                                        , NVL(SUM(AMOUNT_REBATE),0) CLC_REBATE_AMT
                                FROM
                                    (
                                     SELECT  /*+ PARALLEL*/ 
                                             A.COMPANY_BRANCH_CODE ,  A.SAMITY_CODE , A.MEMBER_ID, A.LOAN_CODE , A.DAFA_NO 
                                                , A.TTL_INSTALL_AMT_RCVD , A.AMOUNT_REBATE, 
                                              DECODE (
                                                 A.INSTALL_TYPE,
                                                 'S', 0,
                                                 'O', ROUND (A.TTL_INSTALL_AMT_RCVD, 2),
                                                 'P', ROUND (A.TTL_INSTALL_PRN_RCVD, 2),
                                                 'R', ROUND (A.TTL_INSTALL_PRN_RCVD, 2),
                                                 'T', ROUND (A.TTL_INSTALL_PRN_RCVD, 2),
                                                 ROUND (
                                                      A.TTL_INSTALL_AMT_RCVD
                                                    * B.DISBURSE_AMT
                                                    / (B.DISBURSE_AMT + B.TTL_SC),
                                                    2))
                                                 AMOUNT_RCVD_PRN,
                                              DECODE (
                                                 A.INSTALL_TYPE,
                                                 'S', A.TTL_INSTALL_AMT_RCVD,
                                                 'O', 0,
                                                 'P', A.TTL_INSTALL_AMT_RCVD - ROUND (A.TTL_INSTALL_PRN_RCVD, 2),
                                                 'R', A.TTL_INSTALL_AMT_RCVD - ROUND (A.TTL_INSTALL_PRN_RCVD, 2),
                                                 'T', ROUND (A.TTL_INSTALL_SC_RCVD, 2),
                                                   A.TTL_INSTALL_AMT_RCVD
                                                 -   ROUND (A.TTL_INSTALL_AMT_RCVD, 2)
                                                   * B.DISBURSE_AMT
                                                   / (B.DISBURSE_AMT + B.TTL_SC))
                                                 AMOUNT_RCVD_SC
                                         FROM COLLECTION_SHEET A, LOAN_BAL B
                                        WHERE     (    A.COMPANY_CODE = B.COMPANY_CODE
                                                   AND A.COMPANY_BRANCH_CODE = B.COMPANY_BRANCH_CODE
                                                   AND A.SAMITY_CODE = B.SAMITY_CODE
                                                   AND A.FINANCE_CODE = B.FINANCE_CODE
                                                   AND A.PROJECT_CODE = B.PROJECT_CODE
                                                   AND A.COMPONENT_CODE = B.COMPONENT_CODE
                                                   AND A.MEMBER_ID = B.MEMBER_ID
                                                   AND A.LOAN_CODE = B.LOAN_CODE
                                                   AND A.DAFA_NO = B.DAFA_NO)
                                              AND A.LOAN_CODE IS NOT NULL
                                    AND A.COMPANY_CODE = P_COMPANY
                                    AND A.COMPANY_BRANCH_CODE =   V_BRANCH 
                                    AND A.FINANCE_CODE = P_FINANCE_CODE
                                    AND A.PROJECT_CODE = P_PROJECT_CODE
                                    AND A.COMPONENT_CODE = P_COMPONENT_CODE
                                    AND COLLECT_DATE = V_TANSA_DATE
                                   -- AND A.DEVICE_FLAG IS NOT NULL 
                                )
                                GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                                ) C

                            UNION ALL

                            SELECT I.COMPANY_BRANCH_CODE ,  I.SAMITY_CODE , I.MEMBER_ID,  I.LOAN_CODE , I.DAFA_NO,  0 TTL_DISBURSE, 0 TTL_LOAN_FEE , 0 TTL_INS_AMT , 0 TTL_LIVE_STK_AMT
                                    , 0 TTL_CLC_RCVD , 0 TTL_CLC_PRN_RCVD, 0 CLC_REBATE_AMT
                                    , TTL_IRG_RCVD , TTL_IRG_RCVD_PRN, IRG_RBT_AMT
                                    , 0 ADJUST_AMT , 0 ADJUST_AMT_PRN, 0 ADJUST_AMT_SC, 0 ADJ_REBATE_AMT
                                    , 0 TTL_INS_ADJUST, 0 INS_ADJUST_PRN , 0 INS_ADJUST_SC , 0 INS_REBATE_AMT
                                    , 0 AMOUNT_WO

                            FROM
                                (
                                SELECT  COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO , NVL(SUM(AMOUNT_RCVD),0) TTL_IRG_RCVD
                                            , NVL(SUM(AMOUNT_PRN_RCVD),0) TTL_IRG_RCVD_PRN, NVL(SUM(AMOUNT_REBATE),0) IRG_RBT_AMT
                                FROM LOAN_COLLECTION
                                    WHERE COMPANY_CODE = P_COMPANY
                                    AND COMPANY_BRANCH_CODE = V_BRANCH
									                  AND FINANCE_CODE = P_FINANCE_CODE
                                    AND PROJECT_CODE = P_PROJECT_CODE
                                    AND COMPONENT_CODE = P_COMPONENT_CODE
                                    AND COLLECT_DATE = V_TANSA_DATE
                                GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                                ) I
                            UNION ALL

                            SELECT A.COMPANY_BRANCH_CODE ,  A.SAMITY_CODE , A.MEMBER_ID, A.LOAN_CODE, DAFA_NO , 0 TTL_DISBURSE, 0 TTL_LOAN_FEE , 0 TTL_INS_AMT , 0 TTL_LIVE_STK_AMT
                                    , 0 TTL_CLC_RCVD , 0 TTL_CLC_PRN_RCVD, 0 CLC_REBATE_AMT
                                    , 0 TTL_IRG_RCVD , 0 TTL_IRG_RCVD_PRN, 0 IRG_RBT_AMT
                                    , ADJUST_AMT , ADJUST_AMT_PRN, ADJUST_AMT_SC, ADJ_REBATE_AMT
                                    , 0 TTL_INS_ADJUST, 0 INS_ADJUST_PRN , 0 INS_ADJUST_SC , 0 INS_REBATE_AMT
                                    , 0 AMOUNT_WO
                            FROM
                            (
                                SELECT COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE, DAFA_NO  , NVL(SUM(AMOUNT_ADJUSTED),0)  ADJUST_AMT , NVL(SUM(AMOUNT_PRN_ADJUSTED),0)     
                                ADJUST_AMT_PRN,NVL(SUM(AMOUNT_SC_ADJUSTED),0) ADJUST_AMT_SC , NVL(SUM(AMOUNT_REBATE),0) ADJ_REBATE_AMT
                                FROM LOAN_SAVINGS_ADJUST
                                    WHERE COMPANY_CODE = P_COMPANY
                                    AND COMPANY_BRANCH_CODE = V_BRANCH
									                  AND FINANCE_CODE = P_FINANCE_CODE
                                    AND PROJECT_CODE = P_PROJECT_CODE
                                    AND COMPONENT_CODE = P_COMPONENT_CODE
                                    AND COLLECT_DATE = V_TANSA_DATE
                                GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                            ) A

                            UNION ALL

                            SELECT IA.COMPANY_BRANCH_CODE ,  IA.SAMITY_CODE , IA.MEMBER_ID, IA.LOAN_CODE, IA.DAFA_NO , 0 TTL_DISBURSE, 0 TTL_LOAN_FEE , 0 TTL_INS_AMT , 0 TTL_LIVE_STK_AMT
                                    , 0 TTL_CLC_RCVD , 0 TTL_CLC_PRN_RCVD, 0 CLC_REBATE_AMT
                                    , 0 TTL_IRG_RCVD , 0 TTL_IRG_RCVD_PRN, 0 IRG_RBT_AMT
                                    , 0 ADJUST_AMT , 0 ADJUST_AMT_PRN, 0 ADJUST_AMT_SC, 0 ADJ_REBATE_AMT
                                    , TTL_INS_ADJUST, INS_ADJUST_PRN , INS_ADJUST_SC, REBATE_AMT INS_REBATE_AMT
                                    , 0 AMOUNT_WO
                            FROM
                            (
                                SELECT COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE, DAFA_NO  , SUM(AMOUNT_ADJUSTED) TTL_INS_ADJUST , SUM(AMOUNT_PRN_ADJUSTED) INS_ADJUST_PRN
                                            , SUM(AMOUNT_SC_ADJUSTED) INS_ADJUST_SC , NVL(SUM(AMOUNT_REBATE),0) REBATE_AMT
                                FROM LOAN_INS_ADJUST
                                WHERE COMPANY_CODE = P_COMPANY
                                AND COMPANY_BRANCH_CODE = V_BRANCH
								                AND FINANCE_CODE = P_FINANCE_CODE
                                AND PROJECT_CODE = P_PROJECT_CODE
                                AND COMPONENT_CODE = P_COMPONENT_CODE
                                AND COLLECT_DATE = V_TANSA_DATE
                                GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                            ) IA
                            
                           
                    )
                  GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO     
                )  T  
            JOIN
                (
                    SELECT 
                    COMPANY_BRANCH_CODE , MNYR ,--  V_WKYR, V_TANSA_DATE,
                    SAMITY_CODE ,MEMBER_ID ,LOAN_CODE ,DAFA_NO ,
                    OPENING_LOAN_WSC ,OPENING_DUE_WSC ,OPENING_ADVANCE_WSC ,
                    RECEIVABLE_WSC ,TOTAL_RECEIVED_WSC ,DUE_RCVD_WSC ,REG_RCVD_WSC ,ADV_RCVD_WSC ,
                    OPENING_LOAN_PRN ,OPENING_DUE_PRN ,OPENING_ADVANCE_PRN ,
                    RECEIVABLE_PRN ,TOTAL_RECEIVED_PRN ,DUE_RCVD_PRN ,REG_RCVD_PRN , ADV_RCVD_PRN ,
                    UPDATE_BY ,UPDATE_TIME ,
                    ADVANCE_ADJUST_WSC ,ADVANCE_ADJ_PRN ,
                    MONTH_TTL_RCVBLE_WSC ,MONTH_TTL_RCVBLE_PRN ,MONTH_TTL_REG_RCVD_WSC ,MONTH_TTL_REG_RCVD_PRN ,
                    LOAN_TYPE ,RECOVERY_FLAG ,RECOVERY_DATE ,
                    CLS_LOAN_WSC ,CLS_DUE_WSC ,CLS_ADV_WSC ,
                    CLS_LOAN_PRN ,CLS_DUE_PRN ,CLS_ADV_PRN ,
                    LLP_AGE_CODE_OPN ,LLP_PCT_OPN ,LLP_DAYS_OPN ,
                    INSTALL_AMT ,LLP_CM_DAYS ,LLP_CLASS_OPN ,
                    CM_DUE_WSC ,CM_DUE_PRN ,LLP_CUR_DAYS ,LLP_CUR_CLASS ,
                    DISBURSE_DATE ,DISBURSE_AMT ,NEW_DISBURSE_FLAG ,
                    TR_OUT_FLAG ,TR_IN_FLAG ,CO_ID ,DISBURSE_AMT_WSC 
                    FROM MF_LOAN_REALIZATION
                    WHERE MNYR = V_MNYR
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    ---AND TRANS_DAY = '27-FEB-22'
                ) B
            ON
                (
                   T.COMPANY_BRANCH_CODE = B.COMPANY_BRANCH_CODE
                AND T.SAMITY_CODE = B.SAMITY_CODE
                AND T.MEMBER_ID = B.MEMBER_ID
                AND T.LOAN_CODE = B.LOAN_CODE
                AND T.DAFA_NO = B.DAFA_NO
                )

           LEFT JOIN
                (
                    SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , INSTALL_NO , INSTALL_DT , INSTALL_AMT , PRN_AMT , SC_AMT , ACC_CLOSE_FLAG
                    FROM MF_LRPS_ARCHIVE
                    WHERE MNYR = V_MNYR
                    AND COMPANY_BRANCH_CODE = V_BRANCH
					AND FINANCE_CODE = P_FINANCE_CODE
					AND PROJECT_CODE = P_PROJECT_CODE
					AND COMPONENT_CODE = P_COMPONENT_CODE
                    --AND WKYR = ''
                    AND INSTALL_DT = V_TANSA_DATE
                    AND ACC_CLOSE_FLAG IS NULL

                ) R
            ON
                (
                     T.COMPANY_BRANCH_CODE = R.COMPANY_BRANCH_CODE
                AND T.SAMITY_CODE = R.SAMITY_CODE
                AND T.MEMBER_ID = R.MEMBER_ID
                AND T.LOAN_CODE = R.LOAN_CODE
                AND T.DAFA_NO = R.DAFA_NO
                )

            WHERE NVL(T.TOTAL_RCVD_CLC,0) + NVL(T.TOTAL_IRG_RCVD,0) + NVL(T.TOTAL_ADJ_AMT,0) + NVL(T.TOTAL_INS_ADJUST,0) + NVL(R.INSTALL_AMT,0) > 0 
         --   AND T.MEMBER_ID = '0001115114'
            );


        BEGIN
          --   DBMS_OUTPUT.PUT_LINE('TEST2'||V_BRANCH);
   
           FOR R IN C1
           LOOP


            UPDATE MF_LOAN_REALIZATION_DAY
            SET   TD_REG_RCVD_WSC = R.TD_REG_RCVD_WSC  , TD_DUE_RCVD_WSC = R.TD_DEU_RCVD_WSC  
                , TD_ADV_RCVD_WSC = R.TD_ADV_RCVD_WSC  , TD_ADV_ADJ_WSC = R.TD_ADVANCE_ADJUST_WSC  
                , RECEIVABLE_WSC = R.RECEIVABLE_WSC,  TOTAL_RECEIVED_WSC = R.TOTAL_RECEIVED_WSC
                , DUE_RCVD_WSC = R.DEU_RCVD_WSC_NEW  , REG_RCVD_WSC = R.REG_RCVD_WSC_NEW , ADV_RCVD_WSC = R.ADV_RCVD_WSC_NEW, ADVANCE_ADJUST_WSC = R.ADVANCE_ADJUST_WSC_NEW
                , RECEIVABLE_PRN = R.RECEIVABLE_PRN,  TOTAL_RECEIVED_PRN = R.TOTAL_RECEIVED_PRN
                , DUE_RCVD_PRN = R.DEU_RCVD_PRN_NEW  , REG_RCVD_PRN = R.REG_RCVD_PRN_NEW , ADV_RCVD_PRN = R.ADV_RCVD_PRN_NEW, ADVANCE_ADJ_PRN = R.ADVANCE_ADJ_PRN
                
                --, TD_SAMITY_FLAG = 'Y'
                , TD_RCVBLE_WSC = R.TODAYS_RCVBLE, TD_RCVBLE_PRN = R.TODAYS_RCVBLE_PRN
                , TD_TTL_RCVD_WSC = R.TD_TTL_RCVD, TD_TTL_RCVD_PRN = R.TD_TTL_RCVD_PRN
                , TD_REG_RCVD_PRN = R.TD_REG_RCVD_PRN, TD_ADV_ADJ_PRN = R.TD_ADVANCE_ADJUST_PRN
                , TD_DUE_RCVD_PRN = R.TD_DEU_RCVD_PRN
                , REBATE_AMT = R.REBATE_AMT
                

            WHERE COMPANY_CODE = P_COMPANY
            AND COMPANY_BRANCH_CODE = V_BRANCH
            AND FINANCE_CODE = P_FINANCE_CODE
            AND PROJECT_CODE = P_PROJECT_CODE
            AND COMPONENT_CODE = P_COMPONENT_CODE
            AND MNYR = V_MNYR
            AND TRANS_DAY = V_TANSA_DATE
            AND SAMITY_CODE = R.SAMITY_CODE
            AND MEMBER_ID = R.MEMBER_ID
            AND LOAN_CODE = R.LOAN_CODE
            AND DAFA_NO = R.DAFA_NO
            ;

            COMMIT;


           END LOOP;
       
           
           NULL;

        END;
        
      
          ------------------------------------------- INSERT NEW  LOAN DISBURSE DATA-------------------------------------08112024
          
            DECLARE
                
                CURSOR DB1 IS
                SELECT COMPANY_CODE, COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO , BAL_WKYR, INSTALL_INTERVAL LOAN_TYPE,  DISBURSE_DATE, DISBURSE_AMT
                FROM LOAN_BAL
                WHERE COMPANY_CODE = P_COMPANY
                AND COMPANY_BRANCH_CODE = V_BRANCH
                AND FINANCE_CODE = P_FINANCE_CODE
                AND PROJECT_CODE = P_PROJECT_CODE
                AND COMPONENT_CODE = P_COMPONENT_CODE
                AND DISBURSE_DATE = V_TANSA_DATE
                  --GROUP BY COMPANY_BRANCH_CODE ,  SAMITY_CODE , MEMBER_ID,  LOAN_CODE , DAFA_NO
                ;
            
            
            BEGIN
                
                FOR R IN DB1
                LOOP
                
                    DELETE MF_LOAN_REALIZATION_DAY
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = V_MNYR
                    AND TRANS_DAY = V_TANSA_DATE
                    AND SAMITY_CODE = R.SAMITY_CODE
                    AND MEMBER_ID = R.MEMBER_ID
                    AND LOAN_CODE = R.LOAN_CODE
                    AND DAFA_NO = R.DAFA_NO
                    ;
                    
                    COMMIT;
                
                
                INSERT INTO MF_LOAN_REALIZATION_DAY
                (
                    COMPANY_CODE , COMPANY_BRANCH_CODE , FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE , MNYR , WKYR, TRANS_DAY, SAMITY_CODE ,MEMBER_ID ,LOAN_CODE ,DAFA_NO
                     , DISBURSE_AMT , DISBURSE_DATE, TD_DISBURSE, NEW_DISBURSE_FLAG
                     , CLS_LOAN_PRN
                )
                VALUES
                (
                    P_COMPANY , P_BRANCH , P_FINANCE_CODE, P_PROJECT_CODE, P_COMPONENT_CODE, P_MNYR, V_WKYR, V_TANSA_DATE, R.SAMITY_CODE , R.MEMBER_ID,  R.LOAN_CODE , R.DAFA_NO
                    , R.DISBURSE_AMT ,R.DISBURSE_DATE, R.DISBURSE_AMT, 'Y'
                    , R.DISBURSE_AMT
                );
                    
                
                END LOOP;
            
            END;
        
    
   
        
        
            ----------------------UPDATE CLOSING ---------UPDATE  10-05-23
            DECLARE
                    CURSOR L1 IS 
                    SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO
                    FROM MF_LOAN_REALIZATION
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = P_MNYR
                    ;
                    
                    V_CLC_POSTING NUMBER(8);
            
            BEGIN
                    SELECT COUNT(DEVICE_FLAG) A
                    INTO V_CLC_POSTING
                    FROM COLLECTION_SHEET
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
					AND FINANCE_CODE = P_FINANCE_CODE
					AND PROJECT_CODE = P_PROJECT_CODE
					AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = P_MNYR
                    AND COLLECT_DATE = P_TRANS_DATE
                    --AND FW_ID IS NULL
                    AND DEVICE_FLAG  IS NOT NULL
                    ;
            
                FOR R IN L1
                LOOP
                
                    UPDATE MF_LOAN_REALIZATION_DAY
                    SET    CLS_LOAN_WSC = OPENING_LOAN_WSC  - (NVL(TOTAL_RECEIVED_WSC,0) + NVL(REBATE_AMT,0))
                        ,  CLS_DUE_WSC = OPENING_DUE_WSC + RECEIVABLE_WSC - (REG_RCVD_WSC + DUE_RCVD_WSC + ADVANCE_ADJUST_WSC )
                        ,  CLS_ADV_WSC = 0
                        ,  CLS_LOAN_PRN = OPENING_LOAN_PRN  - TOTAL_RECEIVED_PRN
                        ,  CLS_DUE_PRN = OPENING_DUE_PRN + RECEIVABLE_PRN - (REG_RCVD_PRN + DUE_RCVD_PRN + ADVANCE_ADJ_PRN )
                        ,  CLS_ADV_PRN = 0
                       -- ,  TD_REG_RCVD_WSC = CASE WHEN V_CLC_POSTING = 0 THEN 0 ELSE TD_REG_RCVD_WSC END
                       -- ,  TD_ADV_ADJ_WSC = CASE WHEN V_CLC_POSTING = 0 THEN 0 ELSE TD_ADV_ADJ_WSC END
    
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = P_MNYR
                    AND TRANS_DAY = P_TRANS_DATE
                    AND SAMITY_CODE = R.SAMITY_CODE
                    AND MEMBER_ID = R.MEMBER_ID
                    AND LOAN_CODE = R.LOAN_CODE
                    AND DAFA_NO = R.DAFA_NO
                    ;
                    
                    COMMIT;
                END LOOP;
                
            END;
            /*
            DECLARE ----------------------UPDATE CURRENT MONTH ADVANCE ---------UPDATE  23-10-23
            
                        CURSOR A1 IS
                        SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO 
                                , NVL(CASE WHEN (PRV_RCVD + NVL(OPENING_ADVANCE_WSC,0) + NVL(TD_TTL_RCVD_WSC,0) ) >= RECEIVABLE_WSC THEN PRV_RCVD - PRV_RCVBLE END,0) CM_ADVANCE_WSC
                        FROM
                            (
                                SELECT  COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , OPENING_LOAN_WSC , OPENING_ADVANCE_WSC, RECEIVABLE_WSC,  TOTAL_RECEIVED_WSC
                                            , TD_RCVBLE_WSC , TD_TTL_RCVD_WSC
                                            , NVL(RECEIVABLE_WSC,0) -     NVL(TD_RCVBLE_WSC,0) PRV_RCVBLE
                                            , NVL(TOTAL_RECEIVED_WSC,0) - NVL(TD_TTL_RCVD_WSC,0) PRV_RCVD
                                            --CASE WHEN OPENING_ADVANCE_WSC >=0 AND (TOTAL_RECEIVED_WSC - TD_TTL_RCVD_WSC) > 0 THEN  (TOTAL_RECEIVED_WSC - TD_TTL_RCVD_WSC) END PRV_RCVD
                                FROM MF_LOAN_REALIZATION_DAY
                                WHERE 1 = 1 
                                AND COMPANY_BRANCH_CODE = V_BRANCH
                                AND MNYR = P_MNYR
                                AND TRANS_DAY = P_TRANS_DATE
                                AND NVL(TD_RCVBLE_WSC,0) > 0
                            )
                        ;
            
            BEGIN
                    FOR R IN A1
                    LOOP
                        
                        UPDATE MF_LOAN_REALIZATION_DAY
                        SET CM_ADVANCE_WSC =  R.CM_ADVANCE_WSC
                        WHERE  COMPANY_BRANCH_CODE = V_BRANCH
                        AND MNYR = P_MNYR
                        AND TRANS_DAY = P_TRANS_DATE
                        AND SAMITY_CODE = R.SAMITY_CODE
                        AND MEMBER_ID = R.MEMBER_ID
                        AND LOAN_CODE = R.LOAN_CODE
                        AND DAFA_NO = R.DAFA_NO
                        ;
                        COMMIT;
                                        
                    END LOOP;
                    
            
            
            END;
            */
            
            --------------------------------------------------------------------------------------------------------- IF SAMITY TRANSFER LOAN    UPDATE 01/04/2024
        DECLARE    

           -- V_BRANCH        VARCHAR2(4) := '0215';
            V_SAMITY_LOAN_TR       NUMBER(12);
           -- V_MNYR VARCHAR2(7) := '09/2023'; 

        BEGIN
              
                SELECT COUNT(MEMBER_ID) TR_MEM
                INTO V_SAMITY_LOAN_TR
                FROM MEMBER_TRANSFER_LOAN
                WHERE COMPANY_CODE = P_COMPANY
                AND COMPANY_BRANCH_CODE = V_BRANCH
				AND FINANCE_CODE = P_FINANCE_CODE
				AND PROJECT_CODE = P_PROJECT_CODE
				AND COMPONENT_CODE = P_COMPONENT_CODE
                AND BAL_MNYR = V_MNYR
                ;

        
        IF V_SAMITY_LOAN_TR > 0  THEN  ----------------------- IF SAMITY LOAN TRANSFER 
            
             DECLARE

                CURSOR STL_1 IS 

                   SELECT TR.COMPANY_BRANCH_CODE , TR.SAMITY_CODE , TR.MEMBER_ID , TR.LOAN_CODE , TR.TRANSFER_DATE , TR.BAL_MNYR 
                        , TR.TR_SAMITY_CODE , TR.TR_MEMBER_ID , TR.TR_LOAN_CODE , TR.TR_DAFA_NO 
                        , TR.TR_LOAN_OUTSTANDING , TR.TR_LOAN_OVERDUE , TR.TR_LOAN_ADVANCE
                        , ROUND(TR.TR_LOAN_OUTSTANDING_PRN) TR_LOAN_OUT_PRN , ROUND(TR.TR_LOAN_OVERDUE_PRN) TR_OD_PRN 
                        , ROUND(TR.TR_LOAN_ADVANCE_PRN) TR_ADV_PRN
                        , LR.RECEIVABLE_WSC , LR.RECEIVABLE_PRN
                    FROM MEMBER_TRANSFER_LOAN TR
                    JOIN 
                            (
                                SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , RECEIVABLE_WSC, RECEIVABLE_PRN
                                FROM MF_LOAN_REALIZATION
                                WHERE COMPANY_CODE = P_COMPANY
                                AND COMPANY_BRANCH_CODE = V_BRANCH
                                AND FINANCE_CODE = P_FINANCE_CODE
                                AND PROJECT_CODE = P_PROJECT_CODE
                                AND COMPONENT_CODE = P_COMPONENT_CODE 
                                AND MNYR = V_MNYR
                              --  AND MEMBER_ID = '0249100026'
                            )  LR
                    ON
                        (
                            TR.COMPANY_BRANCH_CODE = LR.COMPANY_BRANCH_CODE
                        AND TR.SAMITY_CODE = LR.SAMITY_CODE
                        AND TR.MEMBER_ID = LR.MEMBER_ID
                        AND TR.LOAN_CODE = LR.LOAN_CODE
                        AND TR.TR_DAFA_NO = LR.DAFA_NO
                        )

                    WHERE TR.COMPANY_CODE = P_COMPANY
                    AND TR.COMPANY_BRANCH_CODE = V_BRANCH
					AND FINANCE_CODE = P_FINANCE_CODE
					AND PROJECT_CODE = P_PROJECT_CODE
					AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND TR.BAL_MNYR = V_MNYR
                    ;

            BEGIN

                    FOR  R IN STL_1
                    LOOP

                        UPDATE MF_LOAN_REALIZATION_DAY
                        SET TR_OUT_FLAG = 'Y' , CLS_LOAN_WSC = 0 , CLS_LOAN_PRN = 0
                                , CLS_DUE_WSC = 0 , CLS_DUE_PRN = 0
                                , TRANSFER_DATE = R.TRANSFER_DATE
                                , TR_OUT_LOAN_WSC = R.TR_LOAN_OUTSTANDING , TR_OUT_LOAN_PRN = R.TR_LOAN_OUT_PRN
                                , TR_OUT_DUE_WSC = R.TR_LOAN_OVERDUE , TR_OUT_DUE_PRN = R.TR_OD_PRN
                        WHERE COMPANY_CODE = P_COMPANY
                        AND COMPANY_BRANCH_CODE = V_BRANCH
                        AND FINANCE_CODE = P_FINANCE_CODE
                        AND PROJECT_CODE = P_PROJECT_CODE
                        AND COMPONENT_CODE = P_COMPONENT_CODE 
                        AND MNYR = V_MNYR
                        AND TRANS_DAY = P_TRANS_DATE
                        AND SAMITY_CODE = R.SAMITY_CODE
                        AND MEMBER_ID = R.MEMBER_ID
                        AND LOAN_CODE = R.LOAN_CODE
                        AND DAFA_NO = R.TR_DAFA_NO
                        ;

                        COMMIT;


                        UPDATE MF_LOAN_REALIZATION_DAY
                        SET TR_IN_FLAG = 'Y'                                                       

                        , CLS_LOAN_WSC = R.TR_LOAN_OUTSTANDING - NVL(TOTAL_RECEIVED_WSC,0) 
                        , CLS_LOAN_PRN = R.TR_LOAN_OUT_PRN - NVL(TOTAL_RECEIVED_PRN,0) 
                        , CLS_DUE_WSC  = 
                                        CASE WHEN NVL(R.TR_LOAN_OVERDUE,0) > 0 AND NVL(TOTAL_RECEIVED_WSC,0) <=  NVL(R.TR_LOAN_OVERDUE,0) 
                                                  THEN NVL(R.TR_LOAN_OVERDUE,0) - NVL(TOTAL_RECEIVED_WSC,0) END
                        , CLS_DUE_PRN  = 
                                        CASE WHEN NVL(R.TR_OD_PRN,0) > 0 AND ROUND(NVL(TOTAL_RECEIVED_PRN,0)) <=  NVL(R.TR_OD_PRN,0) 
                                                  THEN NVL(R.TR_OD_PRN,0) - ROUND(NVL(TOTAL_RECEIVED_PRN,0))  END
                        , TRANSFER_DATE = R.TRANSFER_DATE
                        , TR_IN_LOAN_WSC = R.TR_LOAN_OUTSTANDING , TR_IN_LOAN_PRN = R.TR_LOAN_OUT_PRN
                        , TR_IN_DUE_WSC = R.TR_LOAN_OVERDUE , TR_IN_DUE_PRN = R.TR_OD_PRN
                        WHERE COMPANY_CODE = P_COMPANY
                        AND COMPANY_BRANCH_CODE = V_BRANCH
                        AND FINANCE_CODE = P_FINANCE_CODE
                        AND PROJECT_CODE = P_PROJECT_CODE
                        AND COMPONENT_CODE = P_COMPONENT_CODE 
                        AND MNYR = V_MNYR
                        AND TRANS_DAY = P_TRANS_DATE
                        AND SAMITY_CODE = R.TR_SAMITY_CODE
                        AND MEMBER_ID = R.TR_MEMBER_ID
                        AND LOAN_CODE = R.TR_LOAN_CODE
                        AND DAFA_NO = R.TR_DAFA_NO
                        ;

                        COMMIT;

                    END LOOP;

            END;
            
            
            
            DECLARE         -------------------- SAMITY TRANSFER CORRECTION---------------------
    
            --V_BRANCH    VARCHAR2(7) := '0032';
        
            CURSOR C1 IS 
                SELECT COMPANY_BRANCH_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO  ,  MAX(TR_OUT_SAMITY) TR_OUT_SAMITY, MAX(TR_IN_SAMITY) TR_IN_SAMITY
                       , SUM(OPENING_LOAN_WSC) OPN_LOAN_WSC , SUM(OPENING_DUE_WSC) OPN_DUE_WSC , SUM(OPENING_ADVANCE_WSC) OPN_ADV_WSC
                    , SUM(OPENING_LOAN_PRN) OPN_LOAN_PRN , SUM(OPENING_DUE_PRN) OPN_DUE_PRN , SUM(OPENING_ADVANCE_PRN) OPN_ADV_PRN
                    ,  SUM(RECEIVABLE_WSC) RCVBLE, SUM(TOTAL_RECEIVED_WSC) TOTAL_RCVD , SUM(REG_RCVD_WSC) REG_RCVD
                    ,  SUM(RECEIVABLE_PRN) RCVBLE_PRN , SUM(TOTAL_RECEIVED_PRN) TOTAL_RCVD_PRN
                    ,  MAX(CASE WHEN TOTAL_RECEIVED_WSC > 0 THEN TR_IN_SAMITY END ) TTL_RCVD_SAMITY 
                    , MAX(ADVANCE_ADJUST_WSC) ADV_ADJ_WSC ,  MAX(ADVANCE_ADJ_PRN) ADV_ADJ_PRN
                FROM
                    (
                    SELECT COMPANY_BRANCH_CODE , SAMITY_CODE TR_OUT_SAMITY, NULL TR_IN_SAMITY,  MEMBER_ID , LOAN_CODE , DAFA_NO
                            , OPENING_LOAN_WSC , OPENING_DUE_WSC , OPENING_ADVANCE_WSC
                            , OPENING_LOAN_PRN  , OPENING_DUE_PRN , OPENING_ADVANCE_PRN
                            , RECEIVABLE_WSC , TOTAL_RECEIVED_WSC , REG_RCVD_WSC
                            , RECEIVABLE_PRN , TOTAL_RECEIVED_PRN , REG_RCVD_PRN
                            , ADVANCE_ADJUST_WSC, ADVANCE_ADJ_PRN
                    FROM MF_LOAN_REALIZATION_DAY
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = V_MNYR
                    AND TRANS_DAY = P_TRANS_DATE
                    --AND MEMBER_ID = '0215100540'
                    AND TR_OUT_FLAG = 'Y'
                    UNION ALL
                    SELECT COMPANY_BRANCH_CODE ,   NULL   TR_OUT_SAMITY    , SAMITY_CODE TR_IN_SAMITY, MEMBER_ID, LOAN_CODE , DAFA_NO
                            , OPENING_LOAN_WSC , OPENING_DUE_WSC , OPENING_ADVANCE_WSC
                            , OPENING_LOAN_PRN  , OPENING_DUE_PRN , OPENING_ADVANCE_PRN
                            , RECEIVABLE_WSC , TOTAL_RECEIVED_WSC , REG_RCVD_WSC
                            , RECEIVABLE_PRN , TOTAL_RECEIVED_PRN , REG_RCVD_PRN
                            , ADVANCE_ADJUST_WSC, ADVANCE_ADJ_PRN
                    FROM MF_LOAN_REALIZATION_DAY
                    WHERE COMPANY_CODE = P_COMPANY
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND MNYR = V_MNYR
                    AND TRANS_DAY = P_TRANS_DATE
                    --AND MEMBER_ID = '0215100540'
                    AND TR_IN_FLAG = 'Y'    
                    )
                GROUP BY COMPANY_BRANCH_CODE , MEMBER_ID, LOAN_CODE , DAFA_NO
                ;


                BEGIN
                    
                    FOR R IN C1
                    LOOP
                        --  IF R.TR_IN_SAMITY = R.TTL_RCVD_SAMITY THEN
                          
                        IF R.RCVBLE > 0 AND R.TOTAL_RCVD > 0  AND  R.TOTAL_RCVD <= R.RCVBLE THEN
                        
                
                            UPDATE MF_LOAN_REALIZATION_DAY
                            SET 
                                RECEIVABLE_WSC = R.RCVBLE, TOTAL_RECEIVED_WSC = R.TOTAL_RCVD,  REG_RCVD_WSC =  R.TOTAL_RCVD , ADV_RCVD_WSC = 0 , DUE_RCVD_WSC = 0
                                , RECEIVABLE_PRN = R.RCVBLE_PRN , TOTAL_RECEIVED_PRN = R.TOTAL_RCVD_PRN, REG_RCVD_PRN = R.TOTAL_RCVD_PRN , ADV_RCVD_PRN = 0 , DUE_RCVD_PRN = 0
                                 , ADVANCE_ADJUST_WSC = R.ADV_ADJ_WSC , ADVANCE_ADJ_PRN = R.ADV_ADJ_PRN 
                            WHERE COMPANY_CODE = P_COMPANY
                            AND COMPANY_BRANCH_CODE = V_BRANCH
                            AND FINANCE_CODE = P_FINANCE_CODE
                            AND PROJECT_CODE = P_PROJECT_CODE
                            AND COMPONENT_CODE = P_COMPONENT_CODE
                            AND MNYR = V_MNYR
                            AND SAMITY_CODE = R.TR_IN_SAMITY
                            AND MEMBER_ID = R.MEMBER_ID
                            AND LOAN_CODE = R.LOAN_CODE
                            AND DAFA_NO = R.DAFA_NO
                         --   AND LOAN_TYPE = 'M'
                           -- AND MEMBER_ID != '0183100129'
                          --  AND OPENING_ADVANCE_WSC = 0
                            ;
                            
                            COMMIT;
                            
                            
                            UPDATE MF_LOAN_REALIZATION_DAY
                            SET 
                                RECEIVABLE_WSC = 0  , TOTAL_RECEIVED_WSC = 0,  REG_RCVD_WSC =  0 , ADV_RCVD_WSC = 0 , DUE_RCVD_WSC = 0
                                , RECEIVABLE_PRN = 0 , TOTAL_RECEIVED_PRN = 0, REG_RCVD_PRN = 0 , ADV_RCVD_PRN = 0 , DUE_RCVD_PRN = 0
                                , ADVANCE_ADJUST_WSC = 0 , ADVANCE_ADJ_PRN = 0 
                            WHERE COMPANY_CODE = P_COMPANY
                            AND COMPANY_BRANCH_CODE = V_BRANCH
                            AND FINANCE_CODE = P_FINANCE_CODE
                            AND PROJECT_CODE = P_PROJECT_CODE
                            AND COMPONENT_CODE = P_COMPONENT_CODE
                            AND MNYR = V_MNYR
                            AND SAMITY_CODE = R.TR_OUT_SAMITY
                            AND MEMBER_ID = R.MEMBER_ID
                            AND LOAN_CODE = R.LOAN_CODE
                            AND DAFA_NO = R.DAFA_NO
                         --   AND LOAN_TYPE = 'M'
                        -- AND MEMBER_ID != '0183100129'
                         --  AND OPENING_ADVANCE_WSC = 0
                            ;
                            
                           COMMIT;
                         
                         ELSIF R.OPN_ADV_WSC <= R.RCVBLE  AND  R.TOTAL_RCVD = 0  
                            THEN
                         
                            UPDATE MF_LOAN_REALIZATION_DAY
                            SET 
                                    RECEIVABLE_WSC = R.RCVBLE , ADVANCE_ADJUST_WSC = R.OPN_ADV_WSC
                                ,  RECEIVABLE_PRN = R.RCVBLE_PRN , ADVANCE_ADJ_PRN = R.OPN_ADV_PRN
                            WHERE COMPANY_CODE = P_COMPANY
                            AND COMPANY_BRANCH_CODE = V_BRANCH
                            AND FINANCE_CODE = P_FINANCE_CODE
                            AND PROJECT_CODE = P_PROJECT_CODE
                            AND COMPONENT_CODE = P_COMPONENT_CODE
                            AND MNYR = V_MNYR
                            AND SAMITY_CODE = R.TR_IN_SAMITY
                            AND MEMBER_ID = R.MEMBER_ID
                            AND LOAN_CODE = R.LOAN_CODE
                            AND DAFA_NO = R.DAFA_NO
                         --   AND LOAN_TYPE = 'M'
                           -- AND OPENING_ADVANCE_WSC = 0
                            ;
                      --         DBMS_OUTPUT.PUT_LINE('Transfer In Samity Update -- Advance Adjust' ||R.TOTAL_RCVD);
                            COMMIT;
                           
                        END IF;
                    END LOOP;
                
                
                END;
            END IF;
        END;
            
            
------------------------------------END OF SAMITY TRANSFER------------------------------------------------
-------------------------------------------- INSERT OTR DAILY INFORMATION FOR PRESERVATION OR HISTORY ------------------------- 11.03.2025----
        DECLARE
            
             V_FY_YEAR       VARCHAR2(7);
        
        BEGIN 
                SELECT    EXTRACT(YEAR FROM ADD_MONTHS (TO_DATE(P_TRANS_DATE), -6))
                                    || '_'
                                    || SUBSTR(EXTRACT(YEAR FROM ADD_MONTHS (TO_DATE(P_TRANS_DATE), 6)),3,2) FISCAL_YEAR
        
                        INTO V_FY_YEAR
                FROM DUAL;
            
            DECLARE ------------------------- Branch Wise 
              
            
            BEGIN
            
                DELETE MF_OTR_INFO_BRANCH_DAY
                WHERE COMPANY_CODE = P_COMPANY
                AND MNYR = V_MNYR
                AND COMPANY_BRANCH_CODE = V_BRANCH
                AND FINANCE_CODE = P_FINANCE_CODE
                AND PROJECT_CODE = P_PROJECT_CODE
                AND COMPONENT_CODE = P_COMPONENT_CODE
                AND TRANSACTION_DAY = P_TRANS_DATE
                ;
                
                COMMIT;
                
                INSERT INTO MF_OTR_INFO_BRANCH_DAY
                (
                    COMPANY_CODE, COMPANY_BRANCH_CODE, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE, FY_YEAR, MNYR, TRANSACTION_DAY
                    , BCD_RECEIVABLE_WSC, BCD_TOTAL_RECEIVED_WSC, BCD_DUE_RCVD_WSC, BCD_REG_RCVD_WSC, BCD_ADV_RCVD_WSC, BCD_ADV_ADJUST_WSC
                    , BCD_OTR_WSC
                    , BCD_RECEIVABLE_PRN, BCD_TOTAL_RECEIVED_PRN, BCD_DUE_RCVD_PRN, BCD_REG_RCVD_PRN, BCD_ADV_RCVD_PRN, BCD_ADV_ADJ_PRN
                    , BCD_OTR_PRN
                    , TD_RECEIVABLE_WSC, TD_TOTAL_RECEIVED_WSC, TD_DUE_RCVD_WSC, TD_REG_RCVD_WSC, TD_ADV_RCVD_WSC, TD_ADV_ADJUST_WSC , TD_OTR_WSC
                    , TD_RECEIVABLE_PRN, TD_TOTAL_RECEIVED_PRN, TD_DUE_RCVD_PRN, TD_REG_RCVD_PRN, TD_ADV_RCVD_PRN, TD_ADV_ADJ_PRN, TD_OTR_PRN
                    , INS_BY, INS_DATE
                )
                (
                    SELECT COMPANY_CODE, A.COMPANY_BRANCH_CODE , FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE, V_FY_YEAR , A.MNYR, A.TRANS_DAY
                    , BCD_RCVBLE_WSC, NVL(BCD_REG_RCVD_WSC,0) + NVL(BCD_DUE_RCVD_WSC,0) + NVL(BCD_ADV_RCVD_WSC,0) , BCD_REG_RCVD_WSC, BCD_DUE_RCVD_WSC, BCD_ADV_RCVD_WSC, BCD_ADV_ADJ_WSC
                        , ROUND( ( NVL(A.BCD_REG_RCVD_WSC,0) +  NVL(A.BCD_ADV_ADJ_WSC,0)) / DECODE(A.BCD_RCVBLE_WSC, 0, .00001, A.BCD_RCVBLE_WSC)  , 4)  * 100 BCD_OTR_WSC
                    
                    , BCD_RECEIVABLE_PRN,  NVL(BCD_DUE_RCVD_PRN,0) +  NVL(BCD_REG_RCVD_PRN,0) + NVL(BCD_ADV_RCVD_PRN,0) , BCD_DUE_RCVD_PRN, BCD_REG_RCVD_PRN, BCD_ADV_RCVD_PRN, BCD_ADV_ADJ_PRN
                         , ROUND( ( NVL(A.BCD_REG_RCVD_PRN,0) +  NVL(A.BCD_ADV_ADJ_PRN,0)) / DECODE(A.BCD_RECEIVABLE_PRN, 0, .00001, A.BCD_RECEIVABLE_PRN)  , 4)  * 100 BCD_OTR_PRN
                    
                    , TD_RECEIVABLE_WSC, NVL(TD_DUE_RCVD_WSC,0) + NVL(TD_REG_RCVD_WSC,0) + NVL(TD_ADV_RCVD_WSC,0) , TD_DUE_RCVD_WSC, TD_REG_RCVD_WSC, TD_ADV_RCVD_WSC, TD_ADV_ADJUST_WSC, TD_OTR_WSC
                    , TD_RECEIVABLE_PRN, NVL(TD_DUE_RCVD_PRN,0) + NVL(TD_REG_RCVD_PRN,0) + NVL(TD_ADV_RCVD_PRN,0) , TD_DUE_RCVD_PRN, TD_REG_RCVD_PRN, TD_ADV_RCVD_PRN, TD_ADV_ADJ_PRN, TD_OTR_PRN
                    , P_USER, SYSDATE
                
                
                FROM 
                    (
                    SELECT COMPANY_CODE , COMPANY_BRANCH_CODE ,TRANS_DAY,  MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE 
                            ,   NVL(SUM(RECEIVABLE_WSC),0) BCD_RCVBLE_WSC , NVL(SUM(REG_RCVD_WSC),0) BCD_REG_RCVD_WSC, NVL(SUM(DUE_RCVD_WSC),0) BCD_DUE_RCVD_WSC
                                    , NVL(SUM(ADV_RCVD_WSC),0) BCD_ADV_RCVD_WSC, NVL(SUM(ADVANCE_ADJUST_WSC),0) BCD_ADV_ADJ_WSC
                                    
                            ,   NVL(SUM(RECEIVABLE_PRN),0) BCD_RECEIVABLE_PRN , NVL(SUM(REG_RCVD_PRN),0) BCD_REG_RCVD_PRN
                                    , NVL(SUM(DUE_RCVD_PRN),0) BCD_DUE_RCVD_PRN , NVL(SUM(ADV_RCVD_PRN),0) BCD_ADV_RCVD_PRN , NVL(SUM(ADVANCE_ADJ_PRN),0) BCD_ADV_ADJ_PRN
                           
                            , NVL(SUM(TD_RCVBLE_WSC),0) TD_RECEIVABLE_WSC  , NVL(SUM(TD_REG_RCVD_WSC),0) TD_REG_RCVD_WSC , NVL(SUM(TD_DUE_RCVD_WSC),0) TD_DUE_RCVD_WSC
                            , NVL(SUM(TD_ADV_RCVD_WSC),0) TD_ADV_RCVD_WSC , NVL(SUM(TD_ADV_ADJ_WSC),0) TD_ADV_ADJUST_WSC 
                            , ROUND((NVL(SUM(TD_REG_RCVD_WSC),0) + NVL(SUM(TD_ADV_ADJ_WSC),0)) / DECODE(NVL(SUM(TD_RCVBLE_WSC),0), 0 , 1, SUM(TD_RCVBLE_WSC))  ,4) * 100 TD_OTR_WSC
                            
                     
                            , NVL(SUM(TD_RCVBLE_PRN),0) TD_RECEIVABLE_PRN , NVL(SUM(TD_REG_RCVD_PRN),0) TD_REG_RCVD_PRN 
                            , NVL(SUM(TD_DUE_RCVD_PRN),0) TD_DUE_RCVD_PRN , NVL(SUM(TD_ADV_RCVD_PRN),0) TD_ADV_RCVD_PRN,  NVL(SUM(TD_ADV_ADJ_PRN),0) TD_ADV_ADJ_PRN
                            , ROUND((NVL(SUM(TD_REG_RCVD_PRN),0) + NVL(SUM(TD_ADV_ADJ_PRN),0)) / DECODE(NVL(SUM(TD_RCVBLE_PRN),0), 0 , 1, SUM(TD_RCVBLE_PRN))  ,4) * 100 TD_OTR_PRN
                            
                    FROM MF_LOAN_REALIZATION_DAY
                    WHERE COMPANY_CODE = P_COMPANY
                    AND MNYR = V_MNYR
                    AND COMPANY_BRANCH_CODE = V_BRANCH
                    AND FINANCE_CODE = P_FINANCE_CODE
                    AND PROJECT_CODE = P_PROJECT_CODE
                    AND COMPONENT_CODE = P_COMPONENT_CODE
                    AND TRANS_DAY = P_TRANS_DATE
                    GROUP BY COMPANY_CODE , COMPANY_BRANCH_CODE , TRANS_DAY, MNYR, FINANCE_CODE, PROJECT_CODE, COMPONENT_CODE
                    ) A
                
                );
            
            END;
        END;     ----------------------------------- END OF OTR HISTORY DATA INSERT  
            
    END;
    
    
END;
    
