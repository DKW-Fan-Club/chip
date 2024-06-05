#!/bin/bash

mkdir hardware/$1
sed {s/MODULE_NAME/$1/} utils/templates/create_module/BUCK.template >> hardware/$1/BUCK
touch hardware/$1/$1.sv
touch hardware/$1/tb.sv
