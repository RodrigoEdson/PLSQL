DECLARE
  vupdate       VARCHAR2(1000);
  v_exec_status NUMBER;

  v_sql_chunk VARCHAR2(1000);
BEGIN

  dbms_parallel_execute.create_task('task_update_teste');

  v_sql_chunk := 'SELECT MIN(id) start_id, ' || --
                 '       MAX(id) end_id ' || --
                 'FROM   (SELECT id_a520_rel_guia_cobranca_lote id, ' || --
                 '               ntile(6) over(ORDER BY id_a520_rel_guia_cobranca_lote DESC) chunk_num ' || --
                 '        FROM   pu_a520_rel_guia_cobranca_lote ' || --
                 '        GROUP  BY id_a520_rel_guia_cobranca_lote) ' || --
                 'GROUP  BY chunk_num ' || --
                 'ORDER  BY 1 ';

  dbms_parallel_execute.create_chunks_by_sql('task_update_teste', v_sql_chunk, FALSE);

  vupdate := 'update pu_a520_rel_guia_cobranca_lote  ' || --
             ' set qtd_lote = 10+ fnc_teste_update' || --
             ' where ID_A520_REL_GUIA_COBRANCA_LOTE BETWEEN :start_id AND :end_id';

  dbms_parallel_execute.run_task('task_update_teste',
                                 vupdate,
                                 dbms_sql.native,
                                 parallel_level => 6);

  v_exec_status := dbms_parallel_execute.task_status('task_update_teste');
  dbms_output.put_line(v_exec_status);

  --dbms_parallel_execute.drop_task('task_update_teste');
END;
