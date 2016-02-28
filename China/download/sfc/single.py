#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()
server.retrieve({
   	 "class": "ei",
   	 "dataset": "interim",
   	 "date": "2015-05-29",
   	 "expver": "1",
   	 "levelist": "46/to/60",
   	 "levtype": "sfc",
   	 "param": "134.128/167.128",
   	 "step": "0",
   	 "stream": "oper",
   	 "target": "20150529_sfc.nc",
	 "format": "netcdf",
   	 "time": "00/06/12/18",
   	 "type": "an",
	 "area": "60/70/10/150",
	 "grid": "0.36/0.36",
})
