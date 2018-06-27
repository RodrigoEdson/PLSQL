CREATE     OR REPLACE VIEW v_country_region AS
   SELECT c.country_id,
          c.country_name,
          r.region_name,
          count(*) over (partition by r.region_ID)countries_region_number
     FROM countries c,
          regions r
    WHERE c.region_id = r.region_id