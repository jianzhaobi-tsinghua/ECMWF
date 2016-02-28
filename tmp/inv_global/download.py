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
   	 "target": "invariant_global.nc",
	 "format": "netcdf",
   	 "time": "12",
   	 "type": "an",
	 "grid": "0.36/0.36",
})
