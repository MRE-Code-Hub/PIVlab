function mean_area=get_mean_of_selection(BW,maptoget)
%returns mean value of selected area
mean_area = mean(maptoget(BW==1),'omitnan');

