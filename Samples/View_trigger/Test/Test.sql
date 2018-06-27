BEGIN
   INSERT   INTO v_country_region (
      country_id,
      country_name,
      region_name
   ) VALUES (
      'UR',
      'Uruguai',
      'South America'
   );
   
   update v_country_region 
   set country_name = 'URUGUAI',
      region_name = 'SOUTH AMERICA 2'
   where country_id = 'UR';
   
   delete from v_country_region 
   where country_id = 'UR';
END;
