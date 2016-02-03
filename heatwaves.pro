pro heatwaves

; get weather and demand data for capital cities
; find heatwaves and look at trends in demand
; use demand forecaster with and without temperature history

; read in the netcdf file
getdemand,demand_dates,demand,price,states
demand_dates = demand_dates - 0.0000000005

; start off with Victoria - need to make this a loop
jj = where(states eq 'VIC1',njj)
if njj eq 0 then stop
demand = reform(demand(jj(0),*))

;trim off data prior to start and end of record
jj = where(demand gt 0,njj)
demand = demand(jj(0):jj(njj-1))
demand_dates = demand_dates(jj(0):jj(njj-1))
plot,demand_dates,demand,xtickunits='time',min_value=0


filename = '/home/UNIMELB/rogerd/BOM_AWS/ALL_AWS.nc'
getweather,filename,AWS_names,AWS_dates,Temperature,Humidity

getvar,'Station_Names',stations,filename

station = stations(3)

jj = where(AWS_names eq station,njj)
if njj eq 0 then stop
Temperature = reform(Temperature(jj(0),*))

;trim off data prior to start and end of record
jj = where(Temperature lt 100,njj)
Temperature = Temperature(jj(0):jj(njj-1))
AWS_dates = AWS_dates(jj(0):jj(njj-1))

plot,AWS_dates,Temperature,xtickunit='time',max_value=100.

; where do our dates overlap?
starttime = max([min(AWS_dates),min(demand_dates)])
endtime = min([max(AWS_dates),max(demand_dates)])

jj = where(demand_dates ge starttime and demand_dates le endtime)
kk = where(AWS_dates ge starttime and AWS_dates le endtime)

dates = demand_dates(jj)
demand = demand(jj)
Temperature = Temperature(kk)

caldat,dates,month,day,year,hour,minute

; get the DOWs
dayofweek,'VIC',demand_dates,DOW

; loop over the years from 2000 to 2014

daytype = ['D','E']
saved_curves = fltarr(2,2,24,15,8)

for iyear = 2000,2014 do BEGIN

    for ihour = 0,23 do BEGIN
        for iminute = 0,30,30 do BEGIN
            for iday = 0,1 do BEGIN
                kk = where(year eq iyear and hour eq ihour  $
                       and Temperature lt 100 and demand gt 0 $
                       and DOW eq daytype(iday) and $
                       minute eq iminute, nkk)
                fit,0,3,temperature(kk),demand(kk),curve
                j = fix(iminute/30)
                saved_curves(iday,j,ihour,iyear-2000,*) = curve
                ;plot,temperature(kk),demand(kk),psym=1
                stop
            endfor
        endfor
    endfor
endfor

stop

end
