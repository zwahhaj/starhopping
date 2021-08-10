About:
This reposity contains IDL scripts and procedures to reduce astronomy data
from the SPHERE instrument at the VLT, particularly data obtained using the
star-hopping RDI technique.

The full set of files described below are still being prepared.

---------------------------------------
Citation:
When using these procedures for publications, you can cite Wahhaj et al. 2021 (A&A, in press):
<<<<<<< HEAD
(https://arxiv.org/abs/2101.08268)
=======
(https://ui.adsabs.harvard.edu/search/q=%20%20author%3A%22%5EWahhaj%22&sort=date%20desc%2C%20bibcode%20desc&p_=0)
>>>>>>> a268fee72458a8b9e444e0ff2cf6001411b63bbc

---------------------------------------
Directories:

main_scripts -
IDL scripts which are used to reduce the data.
Typically, one would have to run a few scripts to get the data fully reduced.

main_procs -
IDL procedures written by Zahed Wahhaj, mainly for star-hopping RDI and
AO image differencing.

sample_data - 
Some sample data files to test the scripts.
<<<<<<< HEAD
These are typically image cubes saved in IDL save files
made by the basic reduction script (irdis_basic_reduc_starhop.idl).

dependencies -
These are mostly IDL code written and kindly made public previously by others.
The authors are indicated in the files themselves.
Tne new code, being made public here for the first time, are mostly written
by Michael C. Liu (IfA, U. of Hawaii)
and we thank him for kindly providing them.
=======
These are typically image cubes saved in IDL save files.

dependencies -
IDL code written by others.
The authors are indicated in the files themselves.
>>>>>>> a268fee72458a8b9e444e0ff2cf6001411b63bbc

---------------------------------------
How to reduce data:

We provide a series of scripts which can be used in
turn to reduce the data fully.
After each script one should verify that the end products
are okay.


--------------------
Sorting files:
The data from several nights, if kept in one directory, can be sorted like so:

sphere_sort_hopsets,data='data_with_raw_calibs',dest='reduc'

where the data and calibration files should be in 'data_with_raw_calibs'
and the directory 'reduc' will be populated with subdirectories like:

day305-cid2623923-IRDIS
which indicates: day_of_year - container_id - instrument_arm

Each of these represent one science + reference data set
<<<<<<< HEAD
(data from one concatenation of science and reference star OBs).
=======
(one concatenation of science and reference star OBs).
>>>>>>> a268fee72458a8b9e444e0ff2cf6001411b63bbc


--------------------
Basic IRDIS Reduction:
For IRDIS, in each dataset directory, one can do the basic reduction
(flatfielding, badpixel removel, bad image removal)
for OBJECT, FLUX and CENTER data cubes, just by running:

irdis_basic_reduc_starhop.idl

--------------------
RDI IRDIS Reduction:

In the same directory, run:

irdis_starhop_reduc.idl

---------------------
IFS reduction:

<<<<<<< HEAD
Scripts coming soon.
=======
Scripts coming soon.
>>>>>>> a268fee72458a8b9e444e0ff2cf6001411b63bbc
