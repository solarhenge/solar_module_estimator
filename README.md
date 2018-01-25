# solar_module_estimator
My Processing 3 Solar Module Estimator Project

Purpose: The Solar Module Estimator Processing 3 Program performs 3 functions:
1. it compares two solar modules (i.e. left side represents the first solar module selected and the right side represents the second solar module selected)
2. it determines the maximum number of solar panels that will fit in given roof areas and a winner for each roof area
3. it summarizes the results for the left and right module for all roof areas and determines the total power output difference and the module winner.
This program will provide more accurate estimates on the total number of modules and total power output when compared to using a combination of satellite imagery and 3rd party tools.

Impetus: I am interested in renewable energy and in the province where I live, Manitoba Hydro offers a solar PV incentive. 
The solar PV incentive program is called the "Solar Energy Program" which is found at the following link: https://www.hydro.mb.ca/environment/solar.shtml

I contacted 4 solar module installation companies which are:
1. Evolve Green
2. Living Skies Solar
3. POWERTEC
4. Solar Manitoba

I received quotations from each of these vendors.
In the quotations each vendor provided different solar modules and different total number of solar modules based on estimated roof areas.
The roof areas are initially determined by satellite images of my property.
The vendor then uses a 3rd party tool to rough in the individual modules.

This roughing in of the individual modules is not accurate. It does not take into consideration buffer areas such as eavestroughs, roof vents, chimneys etc. 
Each vendor was going to supply different modules of different size and of different power output and different quantities.

Since no vendor was willing to come out to take actual roof area measurements until they had a deposit, 
I decided to write a solar module estimator using data supplied by the various vendors and roof area measurements supplied by me.

The inputs to this program are as follows:

modules.txt - this tab delimited file contains the following information:
- Select only two - TRUE or FALSE - set only two rows with a TRUE value for comparison purposes
- Installation Company Name - the name of the installation companies
- Module Company Name - the name of the company that manufactures the modules
- Module Type - the type or product code of the module
- Power Output - the solar module power output in Watts 
- Module dimension length (mm) - the solar module dimension length in millimeters
- Module dimension width (mm) - the solar module dimension width in millimeters
- Module dimension height (mm) - the solar module dimension height in millimeters
- Module dimension length (in) - the solar module dimension length in inches
- Module dimension width (in) - the solar module dimension width in inches
- Module dimension height (in) - the solar module dimension height in inches

modules.txt notes:
- module dimensions in mm will be converted to inches in the program
- inches represent pixels in this program

target_areas.txt - this tab delimited file contains the following information:
- Select at least one - TRUE or FALSE - set at least one row with a TRUE value
- Side of the house - i.e. East, South, West 1st Row Top, West 1st Row Bottom, West 2nd Row etc. AKA roof area
- Center the modules? - TRUE or FALSE - set to TRUE if you want the modules centered in the roof area
- Justify the modules? - TRUE or FALSE - set to TRUE if you want the modules top left and bottom right justified in the roof area
- Eavestrough N? - TRUE or FALSE - set to TRUE if you want a buffer on the North side of the roof area (i.e. leave room for eavestrough)
- Eavestrough E? - TRUE or FALSE
- Eavestrough S? - TRUE or FALSE
- Eavestrough W? - TRUE or FALSE
- Target area length (ft) - target area length in feet (i.e. 11 ft 6 in - this cell will contain 11)
- Target area length (in) - target area length remainder in inches (i.e. 11 ft 6 in - this cell will contain 6)
- Target area width (ft) - target area width in feet (i.e. 11 ft 6 in - this cell will contain 11)
- Target area width (in) - target area width remainder in inches (i.e. 11 ft 6 in - this cell will contain 6)

buffers.txt - this tab delimited file contains the following information:
- Buffer N
- Buffer E
- Buffer S
- Buffer W
- Buffer Eavestrough

buffers.txt notes:
- each pixel represents an inch
- examples:
- set the Buffer values to 0 if you want the solar module to go right to the edge of the roof area
- set the Buffer values to 2 if you want a 2 inch buffer between the edge of the roof area and the solar module
- set the Buffer Eavestrough value to 12 if you want a 12 inch buffer between the edge of the roof area that has an eavestrough and the solar module
