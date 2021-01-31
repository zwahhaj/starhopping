;;Written by Zahed Wahhaj, 2019.
function esotimediff, dtime1o, dtime2o

  dtime1 = repstr(dtime1o,'_',':')
  dtime2 = repstr(dtime2o,'_',':')
  
  dt1 = strsplit(dtime1,'T',/ex)
  dt2 = strsplit(dtime2,'T',/ex)

  ymd1 = strsplit(dt1[0],'-',/ex)
  ymd2 = strsplit(dt2[0],'-',/ex)

  hms1 = strsplit(dt1[1],':',/ex)
  hms2 = strsplit(dt2[1],':',/ex)

  y_diff = float(ymd1[0])-float(ymd2[0])
  m_diff = float(ymd1[1])-float(ymd2[1])
  d_diff = float(ymd1[2])-float(ymd2[2])

  hh_diff = float(hms1[0])-float(hms2[0])
  mm_diff = float(hms1[1])-float(hms2[1])
  ss_diff = float(hms1[2])-float(hms2[2])

  min_val = 60d
  hour_val = min_val*60d
  day_val = hour_val*24d
  month_val = day_val*30.4375d ;;average number of days in a month
  year_val = month_val*12d

  
  time_diff = y_diff*year_val + m_diff*month_val + d_diff*day_val + hh_diff*hour_val + mm_diff*min_val + ss_diff
;;  print,'the time diff is:'
;;
;;  print, y_diff, ' years'
;;  print, m_diff, ' months'
;;  print, d_diff, ' days'
;;
;;  print, hh_diff, ' hours'
;;  print, mm_diff, ' minutes'
;;  print, ss_diff, ' seconds'
  return, time_diff
end
