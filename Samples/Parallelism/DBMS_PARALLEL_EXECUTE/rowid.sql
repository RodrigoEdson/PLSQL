DECLARE
  vupdate       VARCHAR2(1000);
  v_exec_status NUMBER;

  vqtdid NUMBER;
BEGIN

  SELECT ceil(COUNT(*) / 10)
  INTO   vqtdid
  FROM   pu_a520_rel_guia_cobranca_lote;
  dbms_output.put_line(vqtdid);

  dbms_parallel_execute.create_task('task_update_teste');

  dbms_parallel_execute.create_chunks_by_sql('task_update_teste',
                                             'PMPTU',
                                             'PU_A520_REL_GUIA_COBRANCA_LOTE',
                                             TRUE,
                                             vqtdid);

  vupdate := 'update pu_a520_rel_guia_cobranca_lote  ' || --
             ' set qtd_lote = 10+ fnc_teste_update' || --
             ' where rowid BETWEEN :start_id AND :end_id';

  dbms_parallel_execute.run_task('task_update_teste',
                                 vupdate,
                                 dbms_sql.native,
                                 parallel_level => 3);

  v_exec_status := dbms_parallel_execute.task_status('task_update_teste');
  dbms_output.put_line(v_exec_status);

  dbms_parallel_execute.drop_task('task_update_teste');
END;
