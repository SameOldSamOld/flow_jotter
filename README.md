# flow_jotter

# Installation & Running

* Download and Open flow_jotter.R in RStudio
* Source file
* Update all/some/none? [a/s/n]: *a*
* Do you want to install from sources the packages which need compilation? (Yes/no/cancel): *no*
* Navigate to your excel spreadsheet
* A new folder called /flow_jotter_plots/ can be found next to your excel spreadsheet containing all new images

# File setup 

## Column names
* The first character of column names specify the type of graph that will be produced
    * '%' - Percentage plot
    * 'N' - Numerical plot
    * 'M' - MFI plot 

![image](https://user-images.githubusercontent.com/40485627/192911680-0d8a86a1-077a-407d-95c6-abcdef16ae01.png)
    
## Row names
* The left hand side of the column MUST be broken up with an underscore (_)
    * This defines the groups that will be created
    * **example:** PBS_1.fcs PBS_2.fcs PBS_3.fcs HDM_1.fcs HDM_2.fcs HDM_3.fcs will be broken into two groups: PBS PBS PBS and HDM HDM HDM
    * There is no limit on number of groups, but > 1 is preferable

![image](https://user-images.githubusercontent.com/40485627/192911262-33782bff-2656-4e90-bde0-e26d593e67e0.png)
    
## Optional setup
* If you have some columns that you do not wish to have plotted, you can add an additional row after your data with the rowname "Plot"
* If a "plot" row is added, a single "Y" will need to be added at the end of each column that you wish to plot
    

# FAQ 

## Can my excel spreadsheet contain multiple sheets?

Yes, but the groups which you are using must always remain the same throughout every sheet. For example, "PBS" vs "HDM". Additional groups in each sheet will not work.

