close all;

filepath = 'IMAGES/Images/Helicobacter_Pylori_Negative/RA028_1/';
filename = 'RA028_Ab_20x_1_Composite_with_selection.tif';

[Next_Obs, Next_Sel, m,n] = Generate_Training_Data(filepath, filename);


Observed = horzcat(Observed,Next_Obs);
Selection = horzcat(Selection, Next_Sel);
files_seen = horzcat(files_seen,strcat(filepath,filename));
