-- drops oracle scheduler objects created by ODMr in all accounts 
-- Parameters:
-- 1. Action Flags:
--    R = report only, do not drop any objects
--    D = drop only, displays drop command only
--    DR or RD = drop and report
set serveroutput on
set verify off

EXECUTE dbms_output.put_line('');
EXECUTE dbms_output.put_line('Drop Oracle Scheduler Chain objects generated by Data Miner Workflows.');
EXECUTE dbms_output.put_line('');

DECLARE
w_tmp varchar2(30) := ' ';
action varchar2(30) := '&1';
report BOOLEAN := TRUE;
dropchain BOOLEAN := TRUE; 
countObjects integer := 0;
countObjectsDropped integer := 0;
countObjectsFailedToDrop integer := 0;
sql_text varchar2(256); 
v_err_msg  VARCHAR2(4000);
TYPE OBJ_ARRAY IS TABLE OF VARCHAR2(30);
v_users OBJ_ARRAY;
v_chains OBJ_ARRAY;
v_jobs OBJ_ARRAY;

BEGIN
  DBMS_OUTPUT.ENABLE(NULL);
  CASE action
    WHEN 'R' THEN report := TRUE;
    WHEN 'DR' THEN report := TRUE;
    WHEN 'RD' THEN report := TRUE;
    ELSE report := FALSE;
  END CASE;

  CASE action
    WHEN 'D' THEN dropchain := TRUE;
    WHEN 'DR' THEN dropchain := TRUE;
    WHEN 'RD' THEN dropchain := TRUE;
    ELSE dropchain := FALSE;
  END CASE;

  EXECUTE IMMEDIATE
'SELECT p.USER_NAME, w.CHAIN_NAME, j.WORKFLOW_JOB_ID 
FROM ODMRSYS.ODMR$PROJECTS p, ODMRSYS.ODMR$WORKFLOWS w, ODMRSYS.ODMR$WORKFLOW_JOBS j
WHERE p.PROJECT_ID = w.project_id AND j.WORKFLOW_ID = w.WORKFLOW_ID
ORDER BY p.USER_NAME, w.CHAIN_NAME' BULK COLLECT INTO v_users, v_chains, v_jobs;

  FOR i in 1..v_users.COUNT LOOP
    IF (w_tmp != v_chains(i)) THEN
      IF report THEN
          DBMS_OUTPUT.PUT_LINE('Owner.Object: ' || '"' || v_users(i) || '"."' ||
            v_chains(i) || '"  Object Type: CHAIN ');
      END IF;
    
      BEGIN
        IF dropchain THEN
          dbms_scheduler.drop_chain
              ( chain_name => '"' ||v_users(i) || '"."' || v_chains(i) || '"',
                force => TRUE );
          DBMS_OUTPUT.PUT_LINE('Dropped: "' ||v_users(i) || '"."' ||
            v_chains(i) ); 
          countObjectsDropped := countObjectsDropped + 1;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        v_err_msg := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK(), 1, 4000);
        DBMS_OUTPUT.PUT_LINE ('Drop failed: ' || 'Owner.Object: ' || '"' || v_users(i) || '"."' ||
        v_chains(i) || '"  Object Type: CHAIN' || ' Error: ' || v_err_msg );
        countObjectsFailedToDrop := countObjectsFailedToDrop + 1;
      END;    
      countObjects := countObjects + 1;
      w_tmp := v_chains(i);
    END IF;

    -- clean up any orpaned chain jobs (leftover by stopped workflows)
    BEGIN
      IF dropchain THEN
        dbms_scheduler.drop_job
            ( job_name => '"' ||v_users(i) || '"."' || v_jobs(i) || '"',
              force => TRUE );
        DBMS_OUTPUT.PUT_LINE('Owner.Object: ' || '"' || v_users(i) || '"."' ||
          v_jobs(i) || '"  Object Type: JOB ');
        DBMS_OUTPUT.PUT_LINE('Dropped: "' ||v_users(i) || '"."' ||
          v_jobs(i) ); 
        countObjects := countObjects + 1;
        countObjectsDropped := countObjectsDropped + 1;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;  -- ok, since the job supposed to be dropped upon workflow completion
    END;    
  END LOOP;

DBMS_OUTPUT.PUT_LINE
 ('Total Number of Objects: ' || countObjects );
DBMS_OUTPUT.PUT_LINE
 ('Total Number of Objects Dropped: ' || countObjectsDropped );
DBMS_OUTPUT.PUT_LINE
 ('Total Number of Objects Failed to Drop: ' || countObjectsFailedToDrop );

EXCEPTION
WHEN OTHERS THEN
  v_err_msg := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK(), 1, 4000);
  DBMS_OUTPUT.PUT_LINE ('Drop failed: ' || 'All Scheduler Chain objects"' || ' Error: ' || v_err_msg );
END;
/