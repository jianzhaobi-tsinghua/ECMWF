#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": "1989-01-01",
    "expver": "1",
    "grid": "0.25/0.25",
    "levtype": "sfc",
    "param": "129.128",
    "step": "0",
    "stream": "oper",
    "target": "China.nc",
    "time": "12",
	"area": "60/70/10/150",
    "type": "an",
	"format": "netcdf",
	})

