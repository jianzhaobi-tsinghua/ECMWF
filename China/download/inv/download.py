#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()
server.retrieve({
   	 "class": "ei",
   	 "dataset": "interim",
   	 "date": "1989-01-01",
   	 "expver": "1",
   	 "levtype": "sfc",
   	 "param": "129.128",
   	 "step": "0",
   	 "stream": "oper",
   	 "target": "invariant.nc",
	 "format": "netcdf",
   	 "time": "12",
   	 "type": "an",
	 "area": "60/70/10/150",
	 "grid": "0.36/0.36",
})
