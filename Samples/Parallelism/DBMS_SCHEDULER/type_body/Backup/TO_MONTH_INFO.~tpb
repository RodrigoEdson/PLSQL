CREATE OR REPLACE TYPE BODY to_Month_Info AS
  CONSTRUCTOR FUNCTION to_Month_Info(pMonth IN DATE) RETURN SELF AS RESULT AS
    vTruncMonth DATE;
  BEGIN
    --Trunc the pMonth parameter to avoid problems with hours
    vTruncMonth := TRUNC(pMonth, 'MM');
    --Set attributes
    self.firstDay := vTruncMonth;
    self.lastDay  := last_day(vTruncMonth);
    self.qtdDays  := self.lastDay - self.firstDay + 1;
    --
    RETURN;
  END to_Month_Info;
END;
/
