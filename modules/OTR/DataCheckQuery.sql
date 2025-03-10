SELECT *
FROM LOAN_BAL_WKYR
WHERE COMPANY_CODE = '0133'
AND COMPANY_BRANCH_CODE = '003'
AND MNYR = '09/2024';

SELECT SUM(LOAN_RCVBLE_PRN) RECEVABLE_PRN , SUM(LOAN_REG_PRN_RCVD) REG_RCVD_PRN 
FROM LOAN_BAL_WKYR
WHERE COMPANY_CODE = '0133'
AND COMPANY_BRANCH_CODE = '003'
AND MNYR = '09/2024';

SELECT *
FROM MF_LOAN_REALIZATION
WHERE MNYR = '09/2024'
AND COMPANY_BRANCH_CODE = '003';

SELECT LAST_CLS_DATE, SUM(RECEIVABLE_PRN) RECEVABLE_PRN, SUM(REG_RCVD_PRN) REG_RCVD_PRN
FROM MF_LOAN_REALIZATION
WHERE MNYR = '09/2024'
AND COMPANY_BRANCH_CODE = '003'
GROUP BY LAST_CLS_DATE
;


SELECT TRANS_DAY,  SUM(RECEIVABLE_PRN) , SUM(REG_RCVD_PRN) REG_RCVD_PRN
FROM MF_LOAN_REALIZATION_DAY
WHERE MNYR = '09/2024'
AND COMPANY_BRANCH_CODE = '003'
GROUP BY TRANS_DAY
;

DELETE MF_LOAN_REALIZATION_DAY
WHERE MNYR = '09/2024'
AND COMPANY_BRANCH_CODE = '003'
;
COMMIT;

SELECT ZONE_CODE, ZONE_NAME, AREA_NAME
FROM COMPANY_BRANCH_INFO
WHERE COMPANY_BRANCH_CODE = '003'
;

SELECT WKYR, FINANCE_CODE, COMPONENT_CODE, PROJECT_CODE,  SUM(LOAN_RCVBLE_PRN) RECEVABLE_PRN , SUM(LOAN_REG_PRN_RCVD) REG_RCVD_PRN 
FROM LOAN_BAL_WKYR
WHERE COMPANY_CODE = '0133'
AND COMPANY_BRANCH_CODE = '003'
AND MNYR = '09/2024'
GROUP BY WKYR, FINANCE_CODE, COMPONENT_CODE, PROJECT_CODE
;

SELECT *
FROM PROCESS_CONTROL
WHERE COMPANY_CODE = '0133'
AND COMPANY_BRANCH_CODE = '003'
AND MNYR = '09/2024'
;


SELECT SUM(PRN_AMT) RECEIVABLE_PRN
FROM
    (
    SELECT COMPANY_BRANCH_CODE , SAMITY_CODE , MEMBER_ID , LOAN_CODE , DAFA_NO , INSTALL_NO , INSTALL_DT , INSTALL_AMT , PRN_AMT , SC_AMT , ACC_CLOSE_FLAG
    FROM MF_LRPS_ARCHIVE
    WHERE MNYR = '09/2024'
    AND COMPANY_BRANCH_CODE = '003'
    AND FINANCE_CODE = '01'
    AND PROJECT_CODE = '01'
    AND COMPONENT_CODE = '01'
    --AND WKYR = ''
    AND INSTALL_DT = '09-MAR-25'
    AND ACC_CLOSE_FLAG IS NULL
    )
