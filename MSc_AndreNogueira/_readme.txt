
This folder contains datasets to use
and is usually located in	c:\msc\GIT\data


-- Usage:

Do once to get data into your computer:
datasets are stored elsewhere (online) and downloaded with:
>> data_download
where "data_download.m" reads information by running .\data_download_info.m

Do everytime your code needs data:
>> ret= netcam3_data
or choosing a specific dataset by specifying a dataId
>> ret= netcam3_data( dataId )


-- Datasets & simulation SW:

EUROC MAV dataset V1_01_medium
https://projects.asl.ethz.ch/datasets/doku.php?id=kmavvisualinertialdatasets
