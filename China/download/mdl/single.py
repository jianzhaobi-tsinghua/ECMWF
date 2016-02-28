#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()
server.retrieve({
   	 "class": "ei",
   	 "dataset": "interim",
   	 "date": "2008-11-11",
   	 "expver": "1",
   	 "levelist": "46/to/60",
   	 "levtype": "ml",
   	 "param": "130.128/131.128/132.128/138.128",
   	 "step": "0",
   	 "stream": "oper",
   	 "target": "20081111_ml.nc",
	 "format": "netcdf",
   	 "time": "00/06/12/18",
   	 "type": "an",
	 "area": "60/70/10/150",
	 "grid": "0.36/0.36",
})
