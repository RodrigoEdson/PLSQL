create or replace PACKAGE regions_tapi AUTHID definer IS

   SUBTYPE st_countries_number IS NUMBER(10);

   TYPE regions_tapi_rec IS RECORD ( region_id regions.region_id%TYPE,
   region_name regions.region_name%TYPE );
   TYPE regions_tapi_tab IS
      TABLE OF regions_tapi_rec;
/* insert*/
   FUNCTION ins (
      p_region_name   IN regions.region_name%TYPE DEFAULT NULL
   ) RETURN regions.region_id%TYPE;
/* update*/
   PROCEDURE upd (
      p_region_id     IN regions.region_id%TYPE,
      p_region_name   IN regions.region_name%TYPE DEFAULT NULL
   );
/* delete*/
   PROCEDURE del (
      p_region_id   IN regions.region_id%TYPE
   );
/* return the ID of a region name*/
   FUNCTION get_region_id (
      p_region_name   IN regions.region_name%TYPE
   ) RETURN regions.region_id%TYPE;
/* return the number of countries related to the region*/
   FUNCTION get_countries_number (
      p_region_id   IN regions.region_id%TYPE
   ) RETURN st_countries_number;

END regions_tapi;